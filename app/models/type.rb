# frozen_string_literal: true

class Type < ApplicationRecord
  has_many :group_habit_has_types
  has_many :individual_habit_has_types

  has_many :group_habits, through: :group_habit_has_types
  has_many :individual_habits, through: :individual_habit_has_types

  self.primary_key = :id
  validates :name, presence: true # string
  validates :description, presence: true # string
end

class TypeSerializer < ActiveModel::Serializer
  attributes :name, :description
end
