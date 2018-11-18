# frozen_string_literal: true

module Error::Helpers
  class RenderValidations
    def self.json(errors)
      messages = errors.record.errors
      {
        errors:
      messages.details.map do |message|
        type = message.second.first[:error]
        attribute = message.first
        {
          status: get_status(type),
          title: get_title(type),
          details: messages[attribute].first
        }.as_json
      end
      }.as_json
    end

    def self.get_status(message)
      case message
      when :taken
        '409'
      else
        '400'
      end
    end

    def self.get_title(message)
      case message
      when :taken
        'Conflict'
      else
        'Bad Request'
      end
    end

    def self.get_error_code_type(type)
      case type
      when :taken
        '01'
      when :too_short
        '02'
      when :too_long
        '03'
      when :inclusion
        '04'
      when :invalid
        '05'
      else
        '00'
      end
    end

    def self.get_error_code(record, error, type)
      atribute_code = record.attributes.keys.find_index(error.to_s)
      type_code = get_error_code_type(type)
      [atribute_code, type_code].join.to_i
    end
  end
end
