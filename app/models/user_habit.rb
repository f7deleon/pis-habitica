class UserHabit < ApplicationRecord
	belongs_to :users
	belongs_to :habits
end
