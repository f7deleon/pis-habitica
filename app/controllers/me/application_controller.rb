# frozen_string_literal: true

class Me::ApplicationController < ApplicationController
  before_action :set_user
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:token])
  rescue StandardError
    render json: { "errors": [{ "status": 403,
                                "title": 'Forbidden',
                                "details": 'Invalid token' }] }, status: :forbidden
  end
end
