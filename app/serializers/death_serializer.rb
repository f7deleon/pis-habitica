# frozen_string_literal: true

class DeathSerializer < TrackHabitSerializer
  set_type :track
  attribute :is_dead do |_object|
    true
  end
end
