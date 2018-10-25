# frozen_string_literal: true

class TrackIndividualHabit < ApplicationRecord
  belongs_to :individual_habit, foreign_key: :habit_id

  scope :created_between, lambda { |start_date, end_date|
    where('date >= ? AND date <= ?', start_date, end_date)
  }
end
