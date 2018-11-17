# frozen_string_literal: true

class TrackHabitSerializer
  include FastJsonapi::ObjectSerializer
  set_type :track
  attribute :max_health do |_object, params|
    params[:current_user].max_health
  end
  attributes :health_difference

  # If it's a negative habit do not show experience as it is not affected
  attribute :max_experience do |_object, params|
    params[:current_user].max_experience
  end
  attribute :experience_difference, if: proc { |record|
    record.experience_difference != 0
  }

  attribute :is_dead, if: proc { |_object, params| params[:current_user].dead? } do |_object|
    true
  end

  belongs_to :group_habit, record_type: :group_habit, serializer: :group_habit, id_method_name: :habit_id,
                           if: proc { |object| object.try(:group_habit) }

  belongs_to :individual_habit,
             record_type: :individual_habit,
             serializer: :individual_habit,
             id_method_name: :habit_id,
             if: proc { |object| object.try(:individual_habit) }
end
