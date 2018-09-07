# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :group_types

  has_many :group_habits
  has_many :track_group_habits, through: :group_habits
  has_many :user_groups
  has_many :users, through: :user_groups

  self.primary_key = :id
  validates :name, presence: true # string
  validates :description, presence: true # string
end
