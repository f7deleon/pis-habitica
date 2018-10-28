# frozen_string_literal: true

class GroupHabitSerializer
  include FastJsonapi::ObjectSerializer

  set_id :id
  attributes :name, :description, :difficulty, :privacy, :frequency, :negative
  has_many :types
end
