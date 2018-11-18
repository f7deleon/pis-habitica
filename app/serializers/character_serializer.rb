# frozen_string_literal: true

class CharacterSerializer
  include FastJsonapi::ObjectSerializer
  set_type :character
  attributes :name, :description
end
