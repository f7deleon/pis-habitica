# frozen_string_literal: true

class IndividualHabitHasType < ApplicationRecord
  belongs_to :individual_habit
  belongs_to :type

  self.primary_key = :individual_habit_id, :type_id
end
