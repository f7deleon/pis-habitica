# frozen_string_literal: true

class GroupHabitInfoSerializer
  include FastJsonapi::ObjectSerializer

  set_type :group_habit
  set_id :id
  attributes :name, :frequency, :negative
  attribute :count_track do |object, params|
    time_zone = params && params['time_zone'] ? params['time_zone'] : UTC_HOURS
    now = Time.now.in_time_zone(time_zone.hours).to_date
    if object.instance_of? GroupHabit
      object.track_group_habits.count do |track|
        track.date.in_time_zone(time_zone.hours).to_date == now &&
          track.user_id == params[:id]
      end
    else
      object.track_individual_habits.count { |track| track.date.in_time_zone(time_zone.hours).to_date == now }
    end
  end
end
