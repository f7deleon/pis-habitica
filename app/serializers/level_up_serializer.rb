# frozen_string_literal: true

class LevelUpSerializer
  include FastJsonapi::ObjectSerializer
  set_type :track
  attribute :health
  attribute :experience
  attribute :max_experience, &:max_experience
  attribute :level_up do |_object|
    true
  end
  attribute :level

  has_one :individual_habit do |object, params|
    object.individual_habits.find(params[:habit])
  end
end
