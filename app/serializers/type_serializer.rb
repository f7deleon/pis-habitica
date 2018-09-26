# frozen_string_literal: true

class TypeSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :description
end
