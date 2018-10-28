# frozen_string_literal: true

class GroupSerializer
  include FastJsonapi::ObjectSerializer

  set_type :group
  set_id :id
  attributes :name, :description
  has_many :users
  has_one :admin do |object|
    object.memberships.find_by_admin(true).user
  end
end
