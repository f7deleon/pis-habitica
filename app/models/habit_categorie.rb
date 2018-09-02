class HabitCategorie < ApplicationRecord
	belongs_to :habit
	belongs_to :categorie
end
