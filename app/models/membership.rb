# frozen_string_literal: true

class Membership < ApplicationRecord
  belongs_to :user, foreign_key: :user_id
  belongs_to :group, foreign_key: :group_id # sender
  validates :admin, inclusion: [true, false]
end
