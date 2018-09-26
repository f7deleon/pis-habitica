# frozen_string_literal: true

class CharacterSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :description
end
