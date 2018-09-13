# frozen_string_literal: true

class TrackIndividualHabit < ApplicationRecord
  belongs_to :individual_habit
  self.primary_key = :individual_habit_id, :date
  scope :created_between, lambda { |start_date, end_date|
    where('date >= ? AND date <= ?', start_date, end_date)
  }
end

class TrackIndividualHabitSerializer < ActiveModel::Serializer
  attributes :individual_habit_id, :date
end
