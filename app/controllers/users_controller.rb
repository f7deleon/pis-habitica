# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show update destroy]

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
    if json_invalid?
      render json: {
        'errors': [
          {
            'status': 400,
            'title': 'Bad request',
            'details': 'Invalid request format'
          }
        ]
      }, status: :bad_request
    else
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
            "attributes": user.serialized,
            "included": [
              {
                "type": 'session',
                "attributes": {
                  "token": user.id.to_s
                }
              }
            ]
          }
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
          "errors": [
            errors
          ]
        }, status: :conflict
      end
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

  private

  def json_invalid?
    !(params[:data][:attributes] &&
      params[:data][:attributes][:nickname] &&
      params[:data][:attributes][:email] &&
      params[:data][:attributes][:password])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:nickname, :mail, :password)
  end
end
