# frozen_string_literal: true

class Type < ActiveRecord::Base
  self.primary_key = :id
  validates :name, presence: true # string
  validates :description, presence: true # string
end
