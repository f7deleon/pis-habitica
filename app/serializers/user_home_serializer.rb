# frozen_string_literal: true

class UserHomeSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :nickname, :email
  has_many :individual_habits
end
