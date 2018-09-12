# frozen_string_literal: true

class IndividualHabit < Habit
  belongs_to :user
  has_many :track_individual_habits, foreign_key: :habit_id
  has_many :individual_habit_has_types, foreign_key: :habit_id
  has_many :types, through: :individual_habit_has_types

  validates :user_id, presence: true
end
