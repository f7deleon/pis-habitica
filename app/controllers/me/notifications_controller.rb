# frozen_string_literal: true

class Me::NotificationsController < Me::ApplicationController
  def index
    notification_list = current_user.notifications
    notification_list = notification_list.select { |item| item.type == params[:type] } unless params[:type].blank?

    options = {}
    options[:include] = %i[sender request]
    options[:params] = { current_user: current_user }
    render json: NotificationSerializer.new(notification_list, options).serialized_json, status: :ok
  end
end
