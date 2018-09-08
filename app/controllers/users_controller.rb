# frozen_string_literal: true

require 'time'

class UsersController < ApplicationController
  before_action :check_params, only: %i[add_character]
  before_action :create_user, only: %i[create]
  before_action :set_user, only: %i[show update destroy add_character]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    user_params = params[:data][:attributes]
    user = User.new(
      nickname: user_params[:nickname],
      mail: user_params[:email],
      password: user_params[:password]
    )

    if user.save
      render json: {
        "data": {
          "id": user.id,
          "type": 'users',
          "attributes": user.serialized
        },
        "included": [
          {
            "type": 'session',
            "attributes": {
              "token": user.id.to_s
            }
          }
        ]
      }, status: :created
    else
      nickname = if User.find_by_nickname(user.nickname)
                   {
                     "status": 409,
                     "code": 1,
                     "title": 'Nickname taken',
                     "details": 'There is already an user with that nickname'
                   }
                 end

      email = if User.find_by_mail(user.mail)
                {
                  "status": 409,
                  "code": 2,
                  "title": 'Email taken',
                  "details": 'There is already an user with that email'
                }
              end
      errors = [nickname, email].compact
      render json: {
        "errors": errors
      }, status: :conflict
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  def add_character
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
  end

  def create_user
    params.require(:data).require(:attributes).require(%i[nickname email password])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  rescue StandardError
    render json: { "errors": [{ "status": 404,
                                "title": 'Not Found',
                                "details": 'User not found.' }] }, status: :not_found
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:nickname, :mail, :password)
  end
end
