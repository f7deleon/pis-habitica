# frozen_string_literal: true

class NotificationSerializer
  include FastJsonapi::ObjectSerializer
  attributes :type, :created_at, :seen

  belongs_to :sender, record_type: :user, serializer: :user_info,
                      if: proc { |record| !record.type.eql? 'PenalizeNotification' } do |record|
    if record.type.eql? 'FriendRequestNotification'
      record.request.user
    elsif record.type.eql? 'FriendshipNotification'
      record.sender
    elsif record.type.eql? 'GroupRequestNotification'
      record.group_request.user
    elsif record.type.eql? 'GroupNotification'
      record.group.memberships.find_by(admin: true).user
    end
  end

  belongs_to :group, record_type: :group, serializer: :group_info,
                     if: proc { |record|
                       record.type.eql?('GroupNotification') ||
                         record.type.eql?('GroupRequestNotification')
                     } do |record|
    if record.type.eql? 'GroupRequestNotification'
      record.group_request.group
    else
      record.group
    end
  end

  belongs_to :request, record_type: :request,
                       serializer: :request, if: proc { |record| record.type.eql? 'FriendRequestNotification' }

  belongs_to :track_individual_habit,
             record_type: :track_individual_habit,
             serializer: :track_habit,
             id_method_name: :track_individual_habit_id,
             if: proc { |record| record.type.eql? 'PenalizeNotification' }

  belongs_to :group_request, record_type: :group_request, serializer: :group_request,
                             if: proc { |record| record.type.eql? 'GroupRequestNotification' }
end
