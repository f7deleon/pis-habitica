# frozen_string_literal: true

module Error
  class CustomError < StandardError
    attr_reader :status, :error, :message

    def initialize(error = nil, status = nil, message = nil)
      @error = error || I18n.t('standard_error')
      @status = status || :unprocessable_entity
      @message = message || I18n.t('standard_error_details')
    end

    def fetch_json
      Helpers::Render.json(error, status, message)
    end
  end
end
