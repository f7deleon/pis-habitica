# frozen_string_literal: true

class Character < ApplicationRecord
  # Relationships
  has_many :user_characters
  has_many :users, through: :user_characters

  # Validatons
  self.primary_key = :id
  validates :name, presence: true # string
  validates :description, presence: true # string
end

class CharacterSerializer < ActiveModel::Serializer
  attributes :id, :name, :description
end
