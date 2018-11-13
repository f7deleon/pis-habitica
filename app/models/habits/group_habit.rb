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
        health_difference: current_user.modify_health(decrement_of_health(current_user)),
        score_difference: score_difference
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
        health_difference: current_user.modify_health(increment_of_health(current_user)),
        score_difference: score_difference
      )
    end
    group.memberships.find_by!(user_id: current_user.id).modify_score(score_difference)
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

  def score_difference
    if negative
      -SCORE_DIFFICULTY_INCREMENT * (4 - difficulty) # -15, -10, -5
    else # Positive
      SCORE_DIFFICULTY_INCREMENT * difficulty # 5, 10, 15
    end
  end

  def undo_track(track_to_delete, current_user)
    score_difference = -track_to_delete.score_difference
    current_user.memberships.find_by!(group_id: group.id).modify_score(-track_to_delete.score_difference)
    experience_difference = current_user.modify_experience(-track_to_delete.experience_difference)
    # Solo se le resta la vida si no habia subido de nivel con este track.
    health_difference = current_user.modify_health(-track_to_delete.health_difference) if current_user.experience >= 0
    track_to_delete.delete
    UndoHabitSerializer.new(
      self,
      params: {
        health_difference: health_difference || 0,
        experience_difference: experience_difference,
        score_difference: score_difference,
        current_user: current_user
      }
    ).serialized_json
  end

  def can_be_seen_by(user)
    if user.belongs?(group)
      true
    else
      # group.privacy = false -> private
      # group.privacy = true -> public
      !group.privacy
    end
  end
end
