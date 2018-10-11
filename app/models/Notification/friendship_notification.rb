# frozen_string_literal: true

class FriendshipNotification < Notification
  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
end
