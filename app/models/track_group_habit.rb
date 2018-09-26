# frozen_string_literal: true

class TrackGroupHabit < ApplicationRecord
  belongs_to :user
  belongs_to :group_habit, foreign_key: :habit_id
end
