# frozen_string_literal: true

class GroupHabit < ApplicationRecord
  belongs_to :group
  has_many :track_group_habits

  has_many :group_habit_has_types
  has_many :types, through: :group_habit_has_types

  self.primary_key = :id
  validates :name, presence: true # string
  validates :description, presence: true # string
  validates :dificulty, presence: true, :inclusion => 1..3 # easy, medium,hard
  validates :privacy, presence: true, :inclusion => 1..3 # public, private, protected
  validates :frecuency, presence: true, :inclusion => 1..2 # default, daily
end
