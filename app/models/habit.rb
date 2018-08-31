class Habit < ApplicationRecord
# == Constants
 VALID_DIFFICULTY_REGEX = /\A(easy|medium|hard)\z/
 VALID_PRIVACY_REGEX = /\A(private|protected|public)\z/

 has_many :user_habits
 has_many :habit_categories
 has_many :users, through: :user_habits
 has_many :categories, through: :habit_categories

 # == Validations
 validates :name, presence: true       # string
 validates :frecuency, presence: true  # integer
 validates :difficulty, presence: true, format: { with: VALID_DIFFICULTY_REGEX } # string
 validates :hasEnd, presence: true     # boolean
 validates :privacy, presence: true, format: { with: VALID_PRIVACY_REGEX } # string
 if :hasEnd then
   validates :endDate, presence: true   # date
 end

 # == Scopes
 # == Callbacks
 # == Class Methods
 # == Instance Methods

end
