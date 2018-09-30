# frozen_string_literal: true

class FriendRequestNotification < Notification
  has_one :request
end
