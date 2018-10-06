# frozen_string_literal: true

class Me::FriendsController < Me::ApplicationController
  before_action :create_friendship, only: %i[create]
  before_action :set_friend, only: %i[destroy]

  # GET me/friends
  # Listar Amigos
  def index
    render json: UserSerializer.new(current_user.friends,
                                    params: { current_user: current_user }).serialized_json, status: :ok
  end

  # POST /me/friends
  # Aceptar Amistad
  def create
    request = current_user.requests_received.find_by!(id: params[:data][:id])

    sender = User.find_by(id: request.user_id)

    # You can't add yourself as a friend
    raise Error::CustomError.new(I18n.t('conflict'), :conflict, I18n.t('errors.messages.self_friend_friendship')) if
      current_user.id == sender.id

    # Sender can't be your friend
    raise Error::CustomError.new(I18n.t('conflict'), :conflict, I18n.t('errors.messages.already_friend')) if
      current_user.friends.find_by(id: sender.id)

    request.destroy

    # El modelo crea automaticamente la amistad reciproca
    friendship = Friendship.new(user_id: sender.id, friend_id: current_user.id)
    friendship.save!

    friendship_notification = FriendshipNotification.new(user_id: sender.id, sender_id: current_user.id)
    friendship_notification.save!

    render json: FriendSerializer.new(sender), status: :created
  end

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
