# frozen_string_literal: true

class Habit < ActiveRecord::Base
  validates :name, presence: true # string
  validates :difficulty, presence: true, inclusion: 1..3 # easy, medium, hard
  validates :privacy, presence: true, inclusion: 1..3 # public, protected, private
  validates :frequency, presence: true, inclusion: 1..2 # default, daily
  validates :active, inclusion: [true, false]
  validates :negative, inclusion: [true, false]
  validate :check_negative_frequency

  before_validation(on: :create) do
    self.active ||= true
    self.negative ||= false
  end

  def check_negative_frequency
    return unless negative && frequency.to_i == 2

    errors.add(:frequency, :invalid)
  end

  # to calculate increments to experience and health
  def increment_of_health(user)
    (user.max_health / 15) + 5 * (difficulty - 1).round
  end

  def increment_of_experience(user)
    (user.max_experience / 15) + 5 * (difficulty - 1).round
  end

  # to calculate decrements to health
  def decrement_of_health(user)
    -((user.max_health / 10) + 5 * (4 - difficulty)).round
  end

  def been_tracked_today?(date)
    track_individual_habits.created_between(
      date.beginning_of_day,
      date.end_of_day
    )
  end
end
