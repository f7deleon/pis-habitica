# frozen_string_literal: true

class GroupHabit < Habit
  belongs_to :group
  has_many :track_group_habits, foreign_key: :habit_id
  has_many :group_habit_has_types, foreign_key: :habit_id
  has_many :types, through: :group_habit_has_types

  self.primary_key = :id
  validates :group_id, presence: true

  def fulfill(date, current_user)
    if negative
      track_habit = TrackGroupHabit.new(
        user_id: current_user.id,
        habit_id: id,
        date: date,
        experience_difference: 0,
        health_difference: current_user.modify_health(decrement_of_health(current_user))
      )
    else # Positive Habit
      # Positive Habit frequency is daily and it has been fulfilled today
      if frequency == 2 && !been_tracked_today_by?(current_user, date).empty?
        raise Error::CustomError.new(I18n.t('conflict'), :conflict, I18n.t('errors.messages.daily_fulfilled'))
      end

      # If frequency = default || has not been fullfilled
      track_habit = TrackGroupHabit.new(
        user_id: current_user.id,
        habit_id: id,
        date: date,
        experience_difference: current_user.modify_experience(increment_of_experience(current_user)),
        health_difference: current_user.modify_health(increment_of_health(current_user))
      )
    end
    track_habit.save!
    track_habit
  end

  def been_tracked_today_by?(user, date)
    track_group_habits.created_between_by(
      user.id,
      date.beginning_of_day,
      date.end_of_day
    )
  end
end
