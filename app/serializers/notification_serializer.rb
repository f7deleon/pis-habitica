# frozen_string_literal: true

class NotificationSerializer
  include FastJsonapi::ObjectSerializer
  attributes :type, :created_at, :seen

  belongs_to :sender, record_type: :user, serializer: :user do |record|
    if record.type.eql? 'FriendRequestNotification'
      record.request.user
    elsif record.type.eql? 'FriendshipNotification'
      record.sender
    end
  end

  belongs_to :request, record_type: :request,
                       serializer: :request, if: proc { |record| record.type.eql? 'FriendRequestNotification' }
end
