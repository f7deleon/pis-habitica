# frozen_string_literal: true

class Request < ApplicationRecord
  belongs_to :user, foreign_key: :user_id # sender
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id

  validates_uniqueness_of :user_id, scope: %i[receiver_id]

  validate :check_uniqueness_of_both_tables
  def check_uniqueness_of_both_tables
    errors.add(:receiver_id, :taken) if Request.find_by(receiver_id: user_id, user_id: receiver_id)
  end
end
