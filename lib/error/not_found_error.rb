# frozen_string_literal: true

module Error
  class NotFoundError < ActiveRecord::RecordNotFound
    def initialize
      super(:record_not_found, 404, e.to_s)
    end
  end
end
