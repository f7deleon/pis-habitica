# frozen_string_literal: true

class CharactersController < ApplicationController
  before_action :authenticate_user
  before_action :set_character, only: %i[show]

  # GET /characters
  def index
    @characters = Character.all

    render json: CharacterSerializer.new(@characters).serialized_json, status: :ok
  end

  # GET /characters/1
  def show
    render json: CharacterSerializer.new(@character).serialized_json, status: :ok
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_character
    @character = Character.find(params[:id])
  end
end
