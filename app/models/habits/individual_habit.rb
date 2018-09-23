# frozen_string_literal: true

class IndividualHabit < Habit
  belongs_to :user
  has_many :track_individual_habits, foreign_key: :habit_id
  has_many :individual_habit_has_types, foreign_key: :habit_id
  has_many :types, through: :individual_habit_has_types

  validates :user_id, presence: true

  def get_sucesive_max(_time_now)
    successive = 0
    max = 0
    before = nil
    track_individual_habits.each do |track_habit|
      # calculo la cantidad de dias seguidos haciendo el habito y el record de dias seguidos
      diference = TimeDifference.between(before, track_habit.date).in_days unless before.nil?
      if !before.nil? && diference < 2
        successive += 1
        max = successive if successive > max
      else
        successive = 0
      end
      # actualizo variables
      before = track_habit.date
    end
    [max, successive]
  end

  def get_porcent_month(time_now)
    count_in_months = 0
    all_days = 0
    porcent_months = 0
    count_all = 0
    porcent = 0
    time_begin = created_at
    porcent_months = 0
    all_porcent = TimeDifference.between(time_begin, time_now).in_days
    before = nil
    fst_month = Time.new(time_now.year, time_now.month, 1)
    track_individual_habits.each do |track_habit|
      porcent = 100
      if TimeDifference.between(track_habit.date, fst_month).in_months < 1 && track_habit.date.month != time_now.month
        count_in_months += 1
        all_days = track_habit.date.end_of_month.day
        porcent_months = ((count_in_months.to_f / all_days.to_f) * 100).round(3)
      end

      # porcentaje de efectividad total
      count_all += 1 if !before.nil? && TimeDifference.between(before, track_habit.date).in_days > 1
      before = track_habit.date
      porcent = 100
    end
    porcent = (count_all / all_porcent) * 100 if all_porcent.positive?
    [porcent_months, porcent]
  end
end
