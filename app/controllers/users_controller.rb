# frozen_string_literal: true

require 'time'

class UsersController < ApplicationController
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
      email: user_params[:email],
      password: user_params[:password]
    )

    raise Error::ConflictError unless user.save!

    token = Knock::AuthToken.new(payload: { sub: user.id }).token
    user_serializer = UserSerializer.new(user)
    render json: {
      "data": user_serializer,
      "included": [
        {
          "type": 'session',
          "attributes": {
            "token": token
          }
        }
      ]
    }, status: :created
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

  private

  def create_user
    params.require(:data).require(:attributes).require(%i[nickname email password])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:token])
  rescue StandardError
    render json: { "errors": [{ "status": 404,
                                "title": 'Not Found',
                                "details": 'User not found.' }] }, status: :not_found
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:nickname, :email, :password)
    raise ActionController::ParameterMissing
  end
end
