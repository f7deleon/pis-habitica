# frozen_string_literal: true

class UserWithFriendSerializer < UserSerializer
  include FastJsonapi::ObjectSerializer
  set_type :user

  has_many :friends
  has_many :groups, serializer: :group_info do |object, params|
    object.groups.select { |e| !e[:privacy] || params[:current_user].memberships.find_by_group_id(e[:id]) }
  end
end
