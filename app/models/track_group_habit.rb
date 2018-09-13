# frozen_string_literal: true

class TrackGroupHabit < ApplicationRecord
  belongs_to :user
  belongs_to :group_habit

  self.primary_key = :user_id, :group_habit_id, :date
end
