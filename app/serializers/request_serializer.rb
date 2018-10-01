# frozen_string_literal: true

class RequestSerializer
  include FastJsonapi::ObjectSerializer
  set_type :request
  set_id :id
  belongs_to :user, record_type: :user, key: :sender
  belongs_to :receiver, record_type: :user
end
