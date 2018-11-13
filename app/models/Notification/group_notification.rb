# frozen_string_literal: true

class GroupNotification < Notification
  belongs_to :group, class_name: 'Group', foreign_key: :group_id
end
