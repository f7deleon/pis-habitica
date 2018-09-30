# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :receiver, class_name: 'User', foreign_key: :user_id
end
