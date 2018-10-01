# frozen_string_literal: true

class Friendship < ApplicationRecord
  after_create :create_inverse_relationship
  after_destroy :destroy_inverse_relationship

  # Validates user is not already your friend
  validates_uniqueness_of :user_id, scope: %i[friend_id]

  belongs_to :user, foreign_key: :user_id # sender
  belongs_to :friend, class_name: 'User', foreign_key: :friend_id

  private

  def create_inverse_relationship
    friend.friendships.create(friend_id: user_id) unless friend.friendships.find_by(friend_id: user_id)
  end

  def destroy_inverse_relationship
    friendship = friend.friendships.find_by(friend_id: user_id)
    friendship&.destroy
  end
end
