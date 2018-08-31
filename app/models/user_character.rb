class UserCharacter < ApplicationRecord
	belongs_to :users
	belongs_to :characters
end
