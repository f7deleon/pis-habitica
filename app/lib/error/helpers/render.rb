# frozen_string_literal: true

module Error::Helpers
  class Render
    def self.json(title, status, message)
      {
        errors: [
          {
            status: status,
            title: title,
            message: message
          }
        ]
      }.as_json
    end
  end
end
