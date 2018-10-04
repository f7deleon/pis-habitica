# frozen_string_literal: true

class FriendSerializer
  include FastJsonapi::ObjectSerializer

  attributes :nickname

  has_one :character do |object|
    object.user_characters&.find_by_is_alive(true)&.character
  end
end
