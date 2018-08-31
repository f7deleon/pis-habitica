class User < ApplicationRecord
	validates :nickname, uniqueness: true
	validates :mail, uniqueness: true
  has_many :user_habits
  has_many :user_characters
  has_many :user_categories
  has_many :habits, through: :user_habits
  has_many :categories, through: :user_categories
  has_many :characters, through: :user_characters
end
