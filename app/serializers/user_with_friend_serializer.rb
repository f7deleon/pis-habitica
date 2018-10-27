# frozen_string_literal: true

class UserWithFriendSerializer < UserSerializer
  include FastJsonapi::ObjectSerializer
  set_type :user

  has_many :friends
end
