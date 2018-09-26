# frozen_string_literal: true

class IndividualHabitHasType < ApplicationRecord
  belongs_to :type
  belongs_to :individual_habit, foreign_key: :habit_id
end
