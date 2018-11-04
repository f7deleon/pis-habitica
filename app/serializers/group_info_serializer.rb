# frozen_string_literal: true

class GroupInfoSerializer
  include FastJsonapi::ObjectSerializer
  set_type :group
  set_id :id

  attributes :name
end
