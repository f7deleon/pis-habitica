# frozen_string_literal: true

class MemberSerializer
  include FastJsonapi::ObjectSerializer
  set_type :user
  set_id :id

  attribute :nickname, &:nickname
  has_one :character do |object|
    object.user_characters.find_by(is_alive: true)&.character
  end

  attribute :level, &:level
end
