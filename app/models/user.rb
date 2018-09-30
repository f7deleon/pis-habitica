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

  has_many :notifications

  has_and_belongs_to_many :friends,
                          class_name: 'User',
                          join_table: :friendships,
                          foreign_key: :user_id,
                          association_foreign_key: :friend_user_id

  has_many :requests_sent, class_name: 'Request', foreign_key: :user_id
  has_many :requests_received, class_name: 'Request', foreign_key: :receiver_id

  self.primary_key = :id
  validates :nickname, presence: true, uniqueness: true # string
  validates :email, presence: true, uniqueness: true # string
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
