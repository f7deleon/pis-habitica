# frozen_string_literal: true

class IndividualHabitSerializer
  include FastJsonapi::ObjectSerializer
  set_type :habit
  set_id :id
  attributes :name, :description, :difficulty, :privacy, :frequency
  attribute :count_track do |object|
    object.track_individual_habits.length
  end
  has_many :types
end
