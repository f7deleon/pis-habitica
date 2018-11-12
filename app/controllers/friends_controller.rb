# frozen_string_literal: true

class FriendsController < ApplicationController
  before_action :set_user, only: %i[index]

  def index
    friends = paginate @user.friends.order('nickname ASC'), per_page: params['per_page']

    render json: UserInfoSerializer.new(friends, params: { current_user: current_user }).serialized_json
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
