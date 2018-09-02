# frozen_string_literal: true

class UserCharacter < ApplicationRecord
  belongs_to :character
  belongs_to :user

  self.primary_key = :character_id, :user_id, :creation_date
  validates :is_alive, presence: true
end
