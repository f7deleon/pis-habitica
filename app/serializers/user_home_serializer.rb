# frozen_string_literal: true

class UserHomeSerializer
  include FastJsonapi::ObjectSerializer
  set_type :user
  attributes :nickname, :health, :level, :experience

  # hacer el calculo de la salud maxima
  attributes :max_health, &:max_health

  # hacer el calculo de la experiencia maxima
  attributes :max_experience, &:max_experience

  attributes :has_notifications do |object|
    object.notifications.where(seen: false).count
  end

  attribute :is_dead, &:dead?

  has_one :character, id_method_name: :alive_character

  has_many :friends

  has_many :individual_habits do |object|
    object.individual_habits.order('name ASC').select(&:active)
  end
end
