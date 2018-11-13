# frozen_string_literal: true

require 'time'
require 'will_paginate/array'

class UsersController < ApplicationController
  skip_before_action :authenticate_user, only: %i[create]
  before_action :create_user, only: %i[create]
  before_action :set_user, only: %i[show update destroy index_habits]

  # GET /users
  def index
    my_friends = current_user.friends.select do |item|
      item.nickname.downcase.include?(params[:filter].downcase)
    end
    my_friends.sort_by! { |friend| friend[:nickname].downcase } unless my_friends.length.zero?
    other_users = User.all.select do |item|
      item.id != current_user.id && item.nickname.downcase.include?(params[:filter].downcase) &&
        !current_user.friends.include?(item)
    end
    other_users.sort_by! { |user| user[:nickname].downcase } unless other_users.length.zero?
    users = paginate my_friends.concat(other_users), per_page: params['per_page'].to_i
    render json: UserInfoSerializer.new(users, params: { current_user: current_user }).serialized_json, status: :ok
  end

  # GET /users/1
  def show
    render json: UserWithFriendSerializer.new(@user, params: { current_user: current_user },
                                                     include: %i[individual_habits friends groups])
                                         .serialized_json, status: :ok
  end

  # GET /users/1/habits
  def index_habits
    habits = paginate @user.get_habits_from_user(current_user), per_page: params[:per_page].to_i
    render json: IndividualHabitInfoSerializer.new(habits).serialized_json
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
    render json: SessionSerializer.json(user, token), status: :created
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: UserSerializer.new(@user).serialized_json, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  # BORRAR BEFORE RELEASE
  def killme
    current_user.death
    current_user.health = 0
    current_user.save
    render json: current_user.dead?, status: :ok
  end

  private

  def create_user
    params.require(:data).require(:attributes).require(%i[nickname email password])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:nickname, :email, :password)
    raise ActionController::ParameterMissing
  end
end
