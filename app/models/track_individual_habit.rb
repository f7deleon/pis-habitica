# frozen_string_literal: true

class TrackIndividualHabit < ApplicationRecord
  belongs_to :individual_habit

  self.primary_key = :individual_habit_id, :date
end
