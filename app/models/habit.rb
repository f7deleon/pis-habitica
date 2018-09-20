# frozen_string_literal: true

class Habit < ActiveRecord::Base
  after_create :set_defaults

  validates :name, presence: true # string
  validates :difficulty, presence: true, inclusion: 1..3 # easy, medium, hard
  validates :privacy, presence: true, inclusion: 1..3 # public, protected, private
  validates :frequency, presence: true, inclusion: 1..2 # default, daily
  validates :active, inclusion: [true, false]

  def set_defaults
    self.active ||= true
  end
end
