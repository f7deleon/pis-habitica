class User < ApplicationRecord
	has_and_belongs_to_many :habits
	has_and_belongs_to_many :categories
	has_and_belongs_to_many :characters
end
