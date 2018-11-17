# frozen_string_literal: true

class TrackGroupHabit < ApplicationRecord
  belongs_to :user
  belongs_to :group_habit, foreign_key: :habit_id

  scope :created_between_by, lambda { |user_id, start_date, end_date|
    where('user_id = ? AND date >= ? AND date <= ?', user_id, start_date, end_date)
  }
end
