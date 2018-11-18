# frozen_string_literal: true

class Me::CharactersController < Me::ApplicationController
  before_action :check_not_alive, only: %i[create]
  before_action :check_params, only: %i[create]
  before_action :set_character, only: %i[create]

  # POST /me/characters
  def create
    user_character = current_user.add_character(@character.id, @date)
    render json: CharacterSerializer.new(@character).serialized_json, status: :created if user_character.save!
  end

  private

  def check_not_alive
    message = I18n.t('errors.messages.alive_character')
    raise Error::CustomError.new(I18n.t('conflict'), '409', message) unless current_user.dead?
  end

  def check_params
    params.require(:data).require(:id)
    params.require(:data).require(:attributes).require(%i[name description])
    params.require(:included)
    date_params = params[:included][0][:attributes][:date]
    unless check_iso8601(date_params)
      raise Error::CustomError.new(I18n.t('bad_request'), :bad_request, I18n.t('errors.messages.date_formatting'))
    end

    @date = Time.zone.parse(date_params)
  end

  def set_character
    @character = Character.find_by!(id: params[:data][:id])
  end

  def check_iso8601(date)
    Time.iso8601(date)
  rescue ArgumentError
    nil
  end
end
