# frozen_string_literal: true

class DeathSerializer < TrackIndividualHabitSerializer
  set_type :track
  attribute :is_dead do |_object|
    true
  end
end
