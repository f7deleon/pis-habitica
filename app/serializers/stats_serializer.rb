# frozen_string_literal: true

class StatsSerializer
  def self.json(data, habit)
    options = {}
    options[:include] = [:types]
    individual_habit_serializer = IndividualHabitSerializer.new(habit, options).serializable_hash
    included_stats = {
      "type": 'stat',
      "attributes": {
        "stat":  { "data": data }
      }
    }

    individual_habit_serializer[:included].insert(0, included_stats)
    individual_habit_serializer
  end
end
