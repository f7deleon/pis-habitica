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
    time_new = Time.new(time.year, time.month, time.day)
    track_list = track_individual_habits.order(:date).select do |track|
      track.health_difference >= 0
    end
    successive = 0
    before = track_list[0] ? track_list[0].date : nil
    difference = 0
    all_successive = []
    time_begin = created_at
    all_percent = TimeDifference.between(time_begin, time_new).in_days.round + 1
    # caso de el mismo dia que creo el habito y consulto estadistica
    all_percent = 1 if TimeDifference.between(time_begin, time_new).in_days.round.zero?
    count_all = 0
    percent = 0
    track_list.each do |track_habit|
      # calculo la cantidad de dias seguidos haciendo el habito y el record de dias seguidos
      difference = TimeDifference.between(before.to_date, track_habit.date.to_date).in_days
      if difference.between?(0, 1)
        successive += 1
      elsif difference > 1
        # el dia que estoy parado ya lo cuento
        successive = 1
      end
      count_all += 1
      all_successive << successive
      # actualizo variables
      before = track_habit.date
    end
    percent = (count_all.to_f / all_percent) * 100 if all_percent.positive?
    percent = percent.round(1)
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
    before = track_order[0] || nil
    unless before.nil?
      track_order.each do |track_habit|
        if TimeDifference.between(before.date.to_date, track_habit.date.to_date).in_days.zero?
          # mismo dia
          count_in_months += 1
        else
          # cambio de dia
          months << { "id": before.id,
                      "habit_id": before.habit_id,
                      "date": before.date,
                      "count_track": count_in_months }
          count_in_months = 1
          before = track_habit
        end
      end
      # El ultimo cambio de dia no se carga, por que se carga luego de la finalizacion
      months << { "id": before.id,
                  "habit_id": before.habit_id,
                  "date": before.date,
                  "count_track": count_in_months }
    end
    months
  end

  def now_calendar(time)
    fst_month = Time.new(time.year, time.month, 1)
    calendar = track_individual_habits.select do |track|
      track.date >= fst_month && (!frequency == 2 || track.health_difference >= 0)
    end
    calendar
  end

  def fulfill(date)
    if negative
      track_individual_habit = TrackIndividualHabit.new(
        habit_id: id,
        date: date,
        experience_difference: 0,
        health_difference: user.health_hypothetical_difference(decrement_of_health(user))
      )
      track_individual_habit.save!
      user.modify_health(decrement_of_health(user))
    else # Positive Habit
      # Positive Habit frequency is daily and it has been fulfilled today
      if frequency == 2 && !been_tracked_today?(date).empty?
        raise Error::CustomError.new(I18n.t('conflict'), :conflict, I18n.t('errors.messages.daily_fulfilled'))
      end

      # If frequency = default || has not been fullfilled
      track_individual_habit = TrackIndividualHabit.new(
        habit_id: id,
        date: date,
        experience_difference: user.modify_experience(increment_of_experience(user)),
        health_difference: user.health_hypothetical_difference(increment_of_health(user))
      )
      track_individual_habit.save!
      user.modify_health(increment_of_health(user))
    end
    track_individual_habit
  end

  def undo_track(track_to_delete)
    experience_difference = user.modify_experience(-track_to_delete.experience_difference)
    # Solo se le resta la vida si no habia subido de nivel con este track.
    health_difference = user.modify_health(-track_to_delete.health_difference) if user.experience >= 0
    track_to_delete.delete
    UndoHabitSerializer.new(
      self,
      params: {
        health_difference: health_difference || 0,
        experience_difference: experience_difference,
        score_difference: 0,
        current_user: user
      }
    ).serialized_json
  end

  def can_be_seen_by(user)
    return true if user.id.equal?(user_id)

    case privacy
    when 1 # public
      true
    when 2 # protected
      user.friend?(self.user)
    else # private
      false
    end
  end
end
