# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Knock::Authenticable
  include Error::ErrorHandler
end
