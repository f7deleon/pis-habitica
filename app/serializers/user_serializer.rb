# frozen_string_literal: true

class UserSerializer
  include FastJsonapi::ObjectSerializer
  STATUS_NO_RELATIONSHIP = 0
  STATUS_REQUEST_SENT = 1
  STATUS_REQUEST_RECEIVED = 2
  STATUS_FRIENDS = 3
  attributes :nickname, :email

  attributes :friendship_status,
             if: proc { |object, params| object.id != params[:current_user].id } do |object, params|
    if params[:current_user].friendships.exists?(friend_id: object.id)
      STATUS_FRIENDS
    elsif params[:current_user].requests_received.exists?(user_id: object.id)
      STATUS_REQUEST_RECEIVED
    elsif params[:current_user].requests_sent.exists?(receiver_id: object.id)
      STATUS_REQUEST_SENT
    else
      STATUS_NO_RELATIONSHIP
    end
  end

  attributes :requests_sent, if: proc { |object, params| object.id != params[:current_user].id } do |object, params|
    if object.requests_sent.exists?(receiver_id: params[:current_user].id)
      true
    else
      false
    end
  end

  has_one :requests_sent do |object, params|
    object.requests_sent.find_by(receiver_id: params[:current_user].id)
  end

  has_one :character do |object|
    object.user_characters&.find_by_is_alive(true)&.character
  end

  has_many :individual_habits do |object, params|
    object.get_habits_from_user(params[:current_user])
  end
end
