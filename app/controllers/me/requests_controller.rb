# frozen_string_literal: true

class Me::RequestsController < Me::ApplicationController
  before_action :set_received_request, only: %i[destroy]
  before_action :check_add_friend, only: %i[create]

  # GET me/requests
  # Listar Solicitudes
  def index
    render json: RequestSerializer.new(current_user.requests_received).serialized_json, status: :ok
  end

  # POST /me/requests/
  # Agregar Amigo
  def create
    receiver = User.find_by!(id: params[:data][:relationships][:receiver][:data][:id])

    # You can't send a friend request to yourself
    if current_user.id == receiver.id
      raise Error::CustomError.new(I18n.t('conflict'), '409', I18n.t('errors.messages.self_friend_request'))
    end

    # This user is already your friend
    if current_user.friends.find_by(id: receiver.id)
      raise Error::CustomError.new(I18n.t('conflict'), '409', I18n.t('errors.messages.already_friend'))
    end

    request = Request.new(
      user_id: current_user.id,
      receiver_id: receiver.id
    )
    raise ActiveRecord::RecordInvalid unless request.save!

    friend_request_notification = FriendRequestNotification.new(user_id: receiver.id, request_id: request.id)
    raise ActiveRecord::RecordInvalid unless friend_request_notification.save!

    render json: RequestSerializer.new(request).serialized_json, status: :created
  end

  # DELETE me/requests/id
  # Rechazar Amistad
  def destroy
    @request.destroy
    render json: {}, status: :no_content
  end

  private

  def check_add_friend
    params.require(:data).require(%i[type])
    params.require(:data).require(:relationships).require(:receiver).require(:data).require(%i[id type])
  end

  def set_received_request
    @request = current_user.requests_received.find_by!(id: params[:id])
  end
end
