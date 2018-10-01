# frozen_string_literal: true

class Me::RequestsController < Me::ApplicationController
  before_action :check_add_friend, only: %i[create]

  # GET me/requests
  # Listar Solicitudes
  # def index

  # POST /me/requests
  # Agregar Amigo #
  def create
    raise ActiveRecord::RecordNotFound unless (
      receiver = User.find_by!(id: params[:data][:relationships][:receiver][:data][:id])
    )

    # You can't send a friend request to yourself
    if current_user.id == receiver.id
      raise Error::CustomError.new(I18n.t('conflict'), :conflict, I18n.t('errors.messages.self_friend_request'))
    end

    # TODO: Agregar codigos de error?
    # This user is already your friend
    if current_user.friends.find_by(id: receiver.id)
      raise Error::CustomError.new(I18n.t('conflict'), :conflict, I18n.t('errors.messages.already_friend'))
    end

    request = Request.new(
      user_id: current_user.id,
      receiver_id: receiver.id
    )
    raise ActiveRecord::RecordInvalid unless request.save!

    friend_request_notification = FriendRequestNotification.new(user_id: receiver.id, request_id: request.id)
    raise ActiveRecord::RecordInvalid unless friend_request_notification.save!

    receiver.notifications << friend_request_notification

    receiver.requests_received << request
    current_user.requests_sent << request

    render json: RequestSerializer.new(request).serialized_json, status: :created
  end

  # DELETE me/requests/id_a_borrar
  # Abandonar Amistad
  # def destroy

  private

  def check_add_friend
    params.require(:data).require(%i[type])
    params.require(:data).require(:relationships).require(:receiver).require(:data).require(%i[id type])
  end
end
