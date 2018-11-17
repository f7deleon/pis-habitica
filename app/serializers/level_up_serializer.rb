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

  has_one :group_habit, if: proc { |_object, params| params[:habit].class.name.eql?('GroupHabit') } do |object, params|
    object.groups.find(params[:habit].group.id).group_habits.find(params[:habit])
  end
  has_one :individual_habit,
          if: proc { |object, params| object.individual_habits.exists?(params[:habit]) } do |object, params|
    object.individual_habits.find(params[:habit])
  end
end
