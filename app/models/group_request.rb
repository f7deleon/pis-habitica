# frozen_string_literal: true

class GroupRequest < ApplicationRecord
  belongs_to :user, foreign_key: :user_id # sender
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id
  belongs_to :group, class_name: 'Group', foreign_key: :group_id

  has_one :group_request_notification, dependent: :destroy

  validates_uniqueness_of :user_id, scope: %i[group_id]
end
