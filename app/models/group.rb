# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :group_types

  has_many :group_habits
  has_many :track_group_habits, through: :group_habits

  has_many :memberships
  has_many :users, through: :memberships, class_name: 'User', foreign_key: :user_id

  validates :privacy, inclusion: [true, false]

  self.primary_key = :id
  validates :name, presence: true # string
end
