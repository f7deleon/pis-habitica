# frozen_string_literal: true

class FriendSerializer
  include FastJsonapi::ObjectSerializer
  set_type :user
  attributes :nickname, :level

  has_one :character do |object|
    object.user_characters&.find_by_is_alive(true)&.character
  end
end
