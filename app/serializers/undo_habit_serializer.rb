# frozen_string_literal: true

class UndoHabitSerializer
  include FastJsonapi::ObjectSerializer
  set_type :track
  set_id :id
  attribute :max_health do |_object, params|
    params[:current_user].max_health
  end
  attribute :health_difference do |_object, params|
    params[:health_difference]
  end
  attribute :max_experience do |_object, params|
    params[:current_user].max_experience
  end
  attribute :experience_difference do |_object, params|
    params[:experience_difference]
  end
  attribute :is_dead, if: proc { |_object, params| params[:current_user].dead? } do
    true
  end
end
