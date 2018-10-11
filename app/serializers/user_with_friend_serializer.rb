# frozen_string_literal: true

class UserWithFriendSerializer < UserSerializer
  include FastJsonapi::ObjectSerializer

  has_many :friends
end
