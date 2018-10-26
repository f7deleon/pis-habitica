# frozen_string_literal: true

class User < ApplicationRecord
  before_validation :set_default, on: :create
  has_many :individual_types
  has_many :track_group_habits

  has_many :individual_habits
  has_many :track_individual_habits, through: :individual_habits
  has_many :user_groups
  has_many :groups, through: :user_groups
  has_many :user_characters
  has_many :characters, through: :user_characters

  has_many :notifications

  has_many :friendships
  has_many :friends, through: :friendships, class_name: 'User', foreign_key: :user_id

  has_many :membership
  has_many :groups, through: :membership, class_name: 'Group', foreign_key: :groups_id

  has_many :requests_sent, class_name: 'Request', foreign_key: :user_id
  has_many :requests_received, class_name: 'Request', foreign_key: :receiver_id

  self.primary_key = :id
  validates :nickname, presence: true, uniqueness: true # string
  validates :email, presence: true, uniqueness: true # string
  validates :password_digest, presence: true, length: { minimum: 8 }

  has_secure_password

  def add_character(char_id, creation_d)
    # check if the user already have a character with is_alive in true
    return nil if user_characters.find_by_is_alive(true)

    # add new UserCharacter record
    user_character = UserCharacter.new(character_id: char_id,
                                       user_id: id,
                                       creation_date: creation_d, is_alive: true)
    self.health = max_health
    # save to database
    if user_character.save
      update_attributes(health: 100)
      user_characters << user_character
      return user_character
    end
    nil
  end

  def get_habits_from_user(user_requester)
    active_habits = individual_habits.order('name ASC').select(&:active)
    if friends.find_by(id: user_requester.id)
      active_habits.reject { |habit| habit.privacy == 3 }
    else
      active_habits.select { |habit| habit.privacy == 1 }
    end
  end

  def set_default
    self.health ||= 0
    self.level ||= 1
    self.experience ||= 0
  end

  def serialized
    UserSerializer.new(self)
  end

  def alive_character
    char = user_characters.find_by_is_alive(true)
    if char.nil?
      nil
    else
      char.character.id
    end
  end

  # to calculate maximum experience and health
  def max_health
    HEALTH_BASE + HEALTH_INCREMENT * (self.level - 1)
  end

  def max_experience
    EXP_BASE + EXP_INCREMENT * (self.level - 1)
  end

  def modify_health(amount)
    if amount.positive?
      if amount + self.health > max_health
        amount = max_health - self.health
        self.health = max_health
      else
        self.health += amount
      end
    else # Penalize
      self.health += amount
      if self.health <= 0
        amount -= self.health # Si tenias 5hp y perdes 15, health_lost = -15 -(-10)
        self.health = 0
        death
      end
    end
    update_attributes(health: health)
    amount
  end

  def modify_experience(amount)
    self.experience = self.experience + amount
    if self.experience >= max_experience
      level_up
    else
      update_attributes(experience: experience)
    end
    amount
  end

  def level_up
    self.experience = self.experience - max_experience
    self.level += 1
    self.health = max_health
    update_attributes(health: health, experience: experience, level: level)
  end

  def death
    user_character = user_characters.find_by!(is_alive: true)
    user_character.update_column(:is_alive, false)
    self.experience = 0
    update_attributes(experience: experience)

    time = Time.zone.now
    individual_habits.each do |habit|
      habit.track_individual_habits.each do |track|
        track.destroy if TimeDifference.between(time.to_date, track.date.to_date).in_days < 1
      end
    end
  end

  def dead?
    user_characters.find_by(is_alive: true).nil?
  end
end
