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
 validates :hasEnd, :inclusion => {:in => [true, false]}
 validates :privacy, presence: true, format: { with: VALID_PRIVACY_REGEX } # string
 validates :endDate, presence: true, if: :hasEnd?   # date

 validates_associated :user_habits
 validates :user_habits, length: {minimum: 1, message: 'should have at least 1 user_habits defined.'}
 #validates :user_habits, presence: true
 validates_associated :users

 #validates :users, presence: true

 #FIXME: Agregar validates_associated de categorias.

 # == Scopes
 # == Callbacks
 # == Class Methods
 # == Instance Methods

end
