# frozen_string_literal: true

class IndividualHabit < ApplicationRecord
  belongs_to :user
  has_many :track_individual_habits

  has_many :individual_habit_has_types
  has_many :types, through: :individual_habit_has_types

  self.primary_key = :id
  validates :name, presence: true # string
  validates :description, presence: true # string
  validates :dificulty, presence: true, inclusion: 1..3 # easy, medium,hard
  validates :privacy, presence: true, inclusion: 1..3 # public, private, protected
  validates :frecuency, presence: true, inclusion: 1..2 # default, daily
end
