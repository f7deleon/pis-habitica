# frozen_string_literal: true

class Me::NotificationsController < Me::ApplicationController
  def index
    notification_list = current_user.notifications
    notification_list = notification_list.select { |item| item.type == params[:type] } unless params[:type].blank?

    notification_list = notification_list.reverse

    options = {}
    options[:include] = %i[sender track_individual_habit track_individual_habit.individual_habit group_request group]
    options[:params] = { current_user: current_user }
    render json: NotificationSerializer.new(notification_list, options).serialized_json, status: :ok

    # update as seen
    notification_list.each do |notification|
      unless notification.seen
        notification.seen = true
        notification.save
      end
    end
  end
end
