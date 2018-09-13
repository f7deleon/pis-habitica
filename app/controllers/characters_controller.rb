# frozen_string_literal: true

class CharactersController < ApplicationController
  before_action :set_character, only: %i[show update destroy]
  before_action :check_user, only: %(index)

  # GET /characters
  def index
    @characters = Character.all

    render json: @characters, each_serializer: CharacterSerializer
  end

  # GET /characters/1
  def show
    render json: @character
  end

  # POST /characters
  def create
    @character = Character.new(character_params)

    if @character.save
      render json: @character, status: :created, location: @character
    else
      render json: @character.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /characters/1
  def update
    if @character.update(character_params)
      render json: @character
    else
      render json: @character.errors, status: :unprocessable_entity
    end
  end

  # DELETE /characters/1
  def destroy
    @character.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_character
    @character = Character.find(params[:id])
  end

  def check_user
    @user = User.find(params[:token])
  rescue StandardError
    render json: { "errors": [{ "status": 403,
                                "title": 'Forbidden',
                                "details": 'Invalid token' }] }, status: :forbidden
  end

  # Only allow a trusted parameter "white list" through.
  def character_params
    params.require(:character).permit(:name, :description)
  end
end
