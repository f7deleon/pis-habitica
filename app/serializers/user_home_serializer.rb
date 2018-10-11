# frozen_string_literal: true

class UserHomeSerializer
  include FastJsonapi::ObjectSerializer
  set_type :user
  attributes :nickname, :health, :level, :experience
  attributes :has_notifications do |object|
    object.notifications.where(seen: false).count
  end

  # hacer el calculo de la salud maxima
  attributes :max_health do |_object|
    100
  end

  # hacer el calculo de la experiencia maxima
  attributes :max_experience do |_object|
    500
  end

  has_one :character do |object|
    object.user_characters.find_by_is_alive(true).character
  end

  has_many :friends

  has_many :individual_habits do |object|
    object.individual_habits.order('name ASC').select(&:active)
  end
end
