# frozen_string_literal: true

module Error
  class UnauthorizedError < Knock.not_found_exception_class
    def initialize
      super(:unauthorized, 401, 'Invalid token')
    end
  end
end
