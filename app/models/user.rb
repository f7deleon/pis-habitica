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

  def add_character(char_id, creation_d)
    # check if the user already have a character with is_alive in true
    return nil if user_characters.find_by_is_alive(true)
    # add new UserCharacter record
    user_character = UserCharacter.new(character_id: char_id,
                                       user_id: id,
                                       creation_date: creation_d, is_alive: true)

    # save to database
    if user_character.save
      user_characters << user_character
      return user_character
    end
    nil
  end

  def serialized
    UserSerializer.new(self)
  end
end

class UserSerializer < ActiveModel::Serializer
  attributes :nickname, :mail
end

class UserHomeSerializer < ActiveModel::Serializer
  attributes :nickname
  has_many :individual_habits
  has_one :character

  def character
    object.user_characters.find_by_is_alive(true).character
  end
end
