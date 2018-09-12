# frozen_string_literal: true

class IndividualType < Type
  has_many :individual_habit_has_types, foreign_key: :type_id
  has_many :individual_habits, through: :individual_habit_has_types

  belongs_to :user
end
