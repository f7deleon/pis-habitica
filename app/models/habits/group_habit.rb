# frozen_string_literal: true

class GroupHabit < Habit
  belongs_to :group
  has_many :track_group_habits, foreign_key: :habit_id
  has_many :group_habit_has_types, foreign_key: :habit_id
  has_many :types, through: :group_habit_has_types

  self.primary_key = :id
  validates :group_id, presence: true
end
