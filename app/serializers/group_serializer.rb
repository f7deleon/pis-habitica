# frozen_string_literal: true

class GroupSerializer
  include FastJsonapi::ObjectSerializer
  set_type :group
  set_id :id

  attributes :name, :description, :privacy

  has_many :members, record_type: :user do |object|
    object.memberships.ordered_by_score_and_name.map(&:user)
  end

  has_one :admin, serializer: :member, record_type: :user do |object|
    object.memberships.find_by_admin(true).user
  end

  has_many :group_habits, serializer: :group_habit, object_method_name: :group_habit do |object|
    object.group_habits.order('name ASC').select(&:active)
  end

  has_many :group_types, serializer: :type do |object|
    object.group_types.order('name ASC')
  end

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
