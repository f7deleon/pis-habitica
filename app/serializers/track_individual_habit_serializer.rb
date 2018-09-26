# frozen_string_literal: true

class TrackIndividualHabitSerializer
  include FastJsonapi::ObjectSerializer
  set_type :track_individual_habit
  set_id :id
  attributes :date
  belongs_to :habit
end
