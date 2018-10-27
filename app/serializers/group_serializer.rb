# frozen_string_literal: true

class GroupSerializer
  include FastJsonapi::ObjectSerializer

  set_type :group
  set_id :id
  attributes :name, :description
  has_many :users
end
