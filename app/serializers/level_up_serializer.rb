# frozen_string_literal: true

class LevelUpSerializer
  include FastJsonapi::ObjectSerializer
  set_type :track
  attribute :health do |_object, params|
    params[:user].health
  end
  attribute :experience do |_object, params|
    params[:user].experience
  end
  attribute :max_experience do |_object, params|
    params[:user].max_experience
  end
  attribute :score_difference, if: proc { |object| object.class.name.eql?('TrackGroupHabit') }
  attribute :level_up do |_object|
    true
  end
  attribute :level do |_object, params|
    params[:user].level
  end

  belongs_to :group_habit, record_type: :group_habit, serializer: :group_habit, id_method_name: :habit_id,
                           if: proc { |object| object.try(:group_habit) }

  belongs_to :individual_habit,
             record_type: :individual_habit,
             serializer: :individual_habit,
             id_method_name: :habit_id,
             if: proc { |object| object.try(:individual_habit) }
end
