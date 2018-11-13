# frozen_string_literal: true

class GroupInfoSerializer
  include FastJsonapi::ObjectSerializer
  REQUEST_NO_SEND = 0
  REQUEST_SEND = 1
  IS_MEMBER = 2
  IS_ADMIN = 3
  set_type :group
  set_id :id

  attributes :name

  attributes :member_count do |object|
    object.users.count
  end

  attributes :group_status do |object, params|
    if params[:current_user].group_requests_sent.find_by(group_id: object.id)
      REQUEST_SEND
    elsif object.memberships.find_by_admin(true).user.id == params[:current_user].id
      IS_ADMIN
    elsif object.users.find_by(id: params[:current_user].id)
      IS_MEMBER
    else
      REQUEST_NO_SEND
    end
  end
end
