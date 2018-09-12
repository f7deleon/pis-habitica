# frozen_string_literal: true

class Me::ApplicationController < ApplicationController
  before_action :authenticate_user
  # Use callbacks to share common setup or constraints between actions.
end
