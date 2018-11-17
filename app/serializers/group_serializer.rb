# frozen_string_literal: true

class GroupSerializer
  include FastJsonapi::ObjectSerializer
  set_type :group
  set_id :id

  attributes :name, :description, :privacy

  has_many :group_types, serializer: :type do |object|
    object.group_types.order('name ASC')
  end

  has_one :current_user, serializer: :member_info, if:
   proc { |object, params| object.users.find_by(id: params[:current_user].id) } do |_object, params|
    params[:current_user]
  end

  has_many :users, serializer: :member_info, if: proc { |_, params| params[:is_create_group] }

  attributes :group_status do |object, params|
    if params[:current_user].group_requests_sent.find_by(group_id: object.id)
      GROUP_REQUEST_SEND
    elsif object.memberships.find_by_admin(true).user.id == params[:current_user].id
      GROUP_IS_ADMIN
    elsif object.users.find_by(id: params[:current_user].id)
      GROUP_IS_MEMBER
    else
      GROUP_REQUEST_NO_SEND
    end
  end
end
