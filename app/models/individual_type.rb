# frozen_string_literal: true

class IndividualType < ApplicationRecord
  belongs_to :type
  belongs_to :user
  self.primary_key = :type_id
end
