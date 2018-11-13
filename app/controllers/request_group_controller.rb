# frozen_string_literal: true

class RequestGroupController < ApplicationController
  before_action :set_group, only: %i[send_request requests]

  def requests
    admin = @group.memberships.find_by!(admin: true).user
    render json: GroupRequestSerializer.new(admin.group_requests_received).serialized_json, status: :ok
  end

  def send_request
    if current_user.memberships.find_by(group_id: @group.id)
      raise Error::CustomError.new(I18n.t('conflict'), :conflict, I18n.t('errors.messages.already_member_group'))
    end

    admin = @group.memberships.find_by!(admin: true).user

    request = GroupRequest.new(
      user_id: current_user.id,
      receiver_id: admin.id,
      group_id: @group.id
    )

    request.save!

    group_request_notification = GroupRequestNotification.new(user_id: admin.id, group_request_id: request.id)
    group_request_notification.save!

    render json: GroupRequestSerializer.new(request).serialized_json, status: :created
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end
end
