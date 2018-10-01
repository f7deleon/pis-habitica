# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

require 'simplecov'
SimpleCov.start 'rails' do
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Serializers', 'app/helpers'
  add_group 'Errors', 'app/lib/error'
end
# Initialize the Rails application.
Rails.application.initialize!
