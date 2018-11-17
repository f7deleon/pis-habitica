# frozen_string_literal: true

class RequestGroupController < ApplicationController
  before_action :set_group, only: %i[send_request requests add_member not_add_member]
  before_action :set_request, only: %i[add_member not_add_member]
  before_action :check_admin, only: %i[add_member not_add_member requests]

  def requests
    admin = @group.memberships.find_by!(admin: true).user
    options = {}
    options[:include] = %i[sender group_request group]
    options[:params] = { current_user: admin }
    notification_list = admin.notifications.select { |notification| notification.type.eql?('GroupRequestNotification') }
    render json: NotificationSerializer.new(notification_list, options).serialized_json, status: :ok
    # update as seen
    notification_list.each do |notification|
      unless notification.seen
        notification.seen = true
        notification.save
      end
    end
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

  def add_member
    request_notification = current_user.notifications.find_by!(group_request_id: @request.id)

    Membership.create(user_id: @request.user_id, group_id: @request.group_id, admin: false)

    request_notification.destroy

    @request.destroy

    group_notification = GroupNotification.new(user_id: @request.user.id, group_id: @request.group_id)

    group_notification.save!

    render json: MemberSerializer.new(@request.user).serialized_json, status: :created
  end

  def not_add_member
    request_notification = current_user.notifications.find_by!(group_request_id: @request.id)

    request_notification.destroy

    @request.destroy

    render json: {}, status: :no_content
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def set_request
    @request = current_user.group_requests_received.find(params[:request])
  end

  def check_admin
    raise Error::CustomError.new(I18n.t(:forbidden), '403', I18n.t('errors.messages.not_admin')) unless
      @group.memberships.find_by(user_id: current_user.id).admin?
  end
end
