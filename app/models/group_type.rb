# frozen_string_literal: true

class GroupType < ApplicationRecord
  belongs_to :type
  belongs_to :group
end
