# frozen_string_literal: true

class GroupSerializer
  include FastJsonapi::ObjectSerializer
  set_type :group
  set_id :id
  attributes :name, :description, :privacy

  has_many :members, record_type: :user do |object|
    @result = object.memberships.where(admin: false).map(&:user)
    @result.sort_by! { |res| res[:nickname] }
  end

  has_one :admin, serializer: :member, record_type: :user do |object|
    object.memberships.find_by_admin(true).user
  end

  has_many :group_habits, serializer: :habit, object_method_name: :group_habit do |object|
    object.group_habits.order('name ASC').select(&:active)
  end
end
