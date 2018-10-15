# frozen_string_literal: true

class IndividualHabitSerializer
  include FastJsonapi::ObjectSerializer
  set_type :habit
  set_id :id
  attributes :name, :description, :difficulty, :privacy, :frequency, :negative
  attribute :count_track do |object|
    now = Time.zone.now
    object.track_individual_habits.select { |track| track.date.to_date == now.to_date }.length
  end
  has_many :types
end
