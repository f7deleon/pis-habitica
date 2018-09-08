# frozen_string_literal: true

class Me::CharactersController < Me::ApplicationController
  before_action :check_params, only: %i[create]

  # POST /me/characters
  def create
    # Check if the creation_date follows iso8601 format
    begin
      Time.iso8601(params[:included][0][:attributes][:date])
    rescue StandardError
      render json: { "errors": [{ "status": 400,
                                  "title": 'Bad request',
                                  "details": 'Invalid creation date format' }] }, status: :bad_request
      return
    end

    # check character existence
    begin
      character_chosen = Character.find(params[:data][:id])
    rescue StandardError
      render json: { "errors": [{ "status": 400,
                                  "title": 'Bad request',
                                  "details": 'Invalid character id' }] }, status: :bad_request
      return
    end

    user_character = @user.add_character(params[:data][:id], params[:included][0][:attributes][:date])
    if user_character
      character_chosen.user_characters << user_character
      render json: character_chosen
    else
      render json: { "errors": [{ "status": 400,
                                  "title": 'Bad request',
                                  "details": 'User already have an alive character' }] }, status: :bad_request
    end
  end

  private

  def check_params
    params.require(:data).require(:id)
    params.require(:included)
    params.require(:token)
  end
end
