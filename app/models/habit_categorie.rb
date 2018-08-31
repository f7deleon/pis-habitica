class HabitCategorie < ApplicationRecord
	belongs_to :habits
	belongs_to :categories
end
