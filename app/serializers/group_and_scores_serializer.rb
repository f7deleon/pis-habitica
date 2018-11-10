# frozen_string_literal: true

class GroupAndScoresSerializer
  def self.json(data, group, group_options)
    serialized_group = GroupSerializer.new(group, group_options).serializable_hash
    included_leaderboard = {
      'type': 'leaderboard',
      'attributes': {
        'leaderboard': data
      }
    }

    serialized_group[:included].push(included_leaderboard)
    serialized_group
  end
end
