class Category < ApplicationRecord
 has_many :user_categories
 has_many :habit_categories
 has_many :users, through: :user_categories
 has_many :habits, through: :habit_categories
end
