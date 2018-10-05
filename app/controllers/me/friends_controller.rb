# frozen_string_literal: true

class Me::FriendsController < Me::ApplicationController
  before_action :create_friend, only: %i[create]
  before_action :set_friend, only: %i[destroy]

  # GET me/friends
  # Listar Amigos
  def index
    render json: UserSerializer.new(current_user.friends,
                                    params: { current_user: current_user }).serialized_json, status: :ok
  end

  # POST /me/friends
  # Aceptar Amistad
  # def create

  # DELETE me/friends
  # Abandonar Amistad
  def destroy
    raise ActiveRecord::RecordNotFound unless (friendship = current_user.friendships.find_by!(friend_id: @friend.id))

    friendship.destroy
    render json: {}, status: :no_content
  end

  private

  def create_friendship
    params.require(:data).require(%i[id type])
  end

  def set_friend
    raise ActiveRecord::RecordNotFound unless (@friend = current_user.friends.find_by!(id: params[:id]))
  end
end
