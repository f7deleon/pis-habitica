# frozen_string_literal: true

class User < ApplicationRecord
  has_many :individual_types
  has_many :track_group_habits

  has_many :individual_habits
  has_many :track_individual_habits, through: :individual_habits
  has_many :user_groups
  has_many :groups, through: :user_groups
  has_many :user_characters
  has_many :characters, through: :user_characters

  self.primary_key = :id
  validates :nickname, presence: true, uniqueness: true # string
  validates :mail, presence: true, uniqueness: true # string
  validates :password, presence: true, length: { minimum: 8 }

  has_secure_password

  def serialized
    UserSerializer.new(self)
  end
end

class UserSerializer < ActiveModel::Serializer
  attributes :id, :nickname, :mail
end
