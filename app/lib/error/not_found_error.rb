# frozen_string_literal: true

module Error
  class NotFoundError < ActiveRecord::RecordNotFound
    def initialize
      super(:record_not_found, 404, I18n.t('not_found'))
    end
  end
end
