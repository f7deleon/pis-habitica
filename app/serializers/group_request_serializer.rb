# frozen_string_literal: true

class GroupRequestSerializer
  include FastJsonapi::ObjectSerializer
  set_type :group_request
  set_id :id
  belongs_to :user, record_type: :user, key: :sender
  belongs_to :receiver, record_type: :user
  belongs_to :group, record_type: :group
end
