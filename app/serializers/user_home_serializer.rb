# frozen_string_literal: true

class UserHomeSerializer
  include FastJsonapi::ObjectSerializer
  set_type :user
  attributes :nickname
  attributes :has_notifications do |object|
    object.notifications.any?
  end

  has_one :character do |object|
    object.user_characters.find_by_is_alive(true).character
  end

  has_many :friends

  has_many :individual_habits do |object|
    object.individual_habits.order('name ASC').select(&:active)
  end
end
