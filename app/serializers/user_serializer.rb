# frozen_string_literal: true

class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :nickname, :email
  attributes :friendships_status do |object, params|
    if params[:current_user].friendships.exists?(friend_id: object.id)
      3
    elsif params[:current_user].requests_received.exists?(user_id: object.id)
      2
    elsif params[:current_user].requests_sent.exists?(receiver_id: object.id)
      1
    else
      0
    end
  end

  attributes :requests_sent do |object, params|
    if object.requests_sent.exists?(receiver_id: params[:current_user].id)
      true
    else
      false
    end
  end

  has_one :character do |object|
    object.user_characters&.find_by_is_alive(true)&.character
  end

  has_many :individual_habits do |object, params|
    active_habits = object.individual_habits.order('name ASC').select(&:active)
    if params[:current_user].friendships.exists?(friend_id: object.id)
      active_habits.reject { |habit| habit.privacy == 3 }
    else
      active_habits.select { |habit| habit.privacy == 1 }
    end
  end
end
