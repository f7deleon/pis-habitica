# frozen_string_literal: true

class GroupType < Type
  has_many :group_habit_has_types, foreign_key: :type_id
  has_many :habits, through: :group_habit_has_types

  belongs_to :group
end
