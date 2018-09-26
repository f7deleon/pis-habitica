# frozen_string_literal: true

class DefaultType < Type
  has_many :group_habit_has_types, foreign_key: :habit_id
  has_many :individual_habit_has_types, foreign_key: :habit_id

  has_many :group_habits, through: :group_habit_has_types
  has_many :individual_habits, through: :individual_habit_has_types
end
