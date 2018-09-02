class UserHabit < ApplicationRecord
	self.primary_keys = :user_id, :habit_id
	belongs_to :user
	belongs_to :habit
end
