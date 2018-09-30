# frozen_string_literal: true

class Request < ApplicationRecord
  belongs_to :user, foreign_key: :user_id # sender
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id
end