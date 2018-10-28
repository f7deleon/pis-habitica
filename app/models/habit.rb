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
end
