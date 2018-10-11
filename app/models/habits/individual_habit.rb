# frozen_string_literal: true

class IndividualHabit < Habit
  belongs_to :user
  has_many :track_individual_habits, foreign_key: :habit_id
  has_many :individual_habit_has_types, foreign_key: :habit_id
  has_many :types, through: :individual_habit_has_types

  validates :user_id, presence: true

  def get_stat_daily(time)
    all_successive, before, percent = get_sucesive_max time
    max = all_successive.max
    successive = all_successive.last
    difference = before ? TimeDifference.between(time, before).in_days : 0
    successive = 0 if difference > 1
    calendar = now_calendar time
    months = []
    [max, successive, percent, calendar, months]
  end

  def get_stat_not_daily(time)
    months = months time
    calendar = now_calendar time
    max = 0
    successive = 0
    percent = 0
    [max, successive, percent, calendar, months]
  end

  def get_sucesive_max(time)
    successive = 0
    before = nil
    difference = 0
    all_successive = []
    time_begin = created_at
    all_percent = TimeDifference.between(time_begin, time).in_days
    count_all = 0
    percent = 0
    track_individual_habits.each do |track_habit|
      percent = 100
      # calculo la cantidad de dias seguidos haciendo el habito y el record de dias seguidos
      if difference.between?(1, 2)
        successive += 1
        count_all += 1
      elsif difference > 2
        successive = 0
      end
      all_successive << successive

      # actualizo variables
      difference = TimeDifference.between(before.to_date, track_habit.date.to_date).in_days if before
      before = track_habit.date
    end
    percent = (count_all / all_percent) * 100 if all_percent.positive?

    [all_successive, before, percent]
  end

  def months(time)
    fst_month = Time.new(time.year, time.month, 1)

    # los ordeno por fecha, aun que ya deberia de estar ordenados
    track_order = track_individual_habits.order(:date).select do |track|
      TimeDifference.between(track.date, fst_month).in_months <= 3 && track.date < fst_month
    end
    months = []
    count_in_months = 0
    before = nil
    track_order.each do |track_habit|
      if before && before.to_date == track_habit.date.to_date
        count_in_months += 1
      else
        # si paso mas de un dia por que pueden haber trackeos el mismo dia
        months << { "id": track_habit.id,
                    "habit_id": track_habit.habit_id,
                    "date": track_habit.date,
                    "count_track": count_in_months }
        count_in_months = 0
      end
      before = track_habit.date
    end
    months
  end

  def now_calendar(time)
    fst_month = Time.new(time.year, time.month, 1)
    calendar = track_individual_habits.select do |track|
      track.date >= fst_month
    end
    calendar
  end
end
