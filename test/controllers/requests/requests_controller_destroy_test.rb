# frozen_string_literal: true

require 'test_helper'

class RequestsControllerDestroyTest < ActionDispatch::IntegrationTest
  def setup
    @sender = User.create(nickname: 'sender', email: 'sender@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @sender.email,
        "password": @sender.password
      }
    }
    @sender_token = JSON.parse(response.body)['jwt']
    @receiver = User.create(nickname: 'receiver', email: 'receiver@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @receiver.email,
        "password": @receiver.password
      }
    }
    @receiver_token = JSON.parse(response.body)['jwt']
    @requestless_user = User.create(nickname: 'requestless_user', email: 'rlu@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @requestless_user.email,
        "password": @requestless_user.password
      }
    }
    @requestless_user_token = JSON.parse(response.body)['jwt']

    @request = Request.create(user_id: @sender.id, receiver_id: @receiver.id)
    @request_notification = FriendRequestNotification.create(user_id: @receiver.id, request_id: @request.id)
  end

  test 'should be valid' do
    assert @sender.valid?
    assert @receiver.valid?
    assert @request.valid?
    assert @requestless_user.valid?
  end

  test 'RechazarAmistad: should destroy friend request' do
    delete '/me/requests/' + @request.id.to_s, headers: {
      'Authorization': 'Bearer ' + @receiver_token
    }
    assert_equal 204, status # No Content
    assert_not FriendRequestNotification.find_by(id: @request_notification.id)
    assert Request.find_by(user_id: @sender.id, receiver_id: @receiver.id).nil?
    assert @sender.requests_sent.find_by(user_id: @sender.id, receiver_id: @receiver.id).nil?
    assert @receiver.requests_received.find_by(user_id: @sender.id, receiver_id: @receiver.id).nil?
  end
  test 'RechazarAmistad: receiver should exist' do
    delete '/me/requests/' + @request.id.to_s, headers: {
      'Authorization': 'Bearer asdasdasd'
    }

    assert_equal 401, status # Unauthorized
  end
  test 'RechazarAmistad: request should exist' do
    delete '/me/requests/123123123124', headers: {
      'Authorization': 'Bearer ' + @receiver_token
    }
    assert_equal 404, status # Not Found
  end
  test 'RechazarAmistad: request should be sent to you' do
    delete '/me/requests/' + @request.id.to_s, headers: {
      'Authorization': 'Bearer ' + @requestless_user_token
    }
    assert_equal 404, status # Not Found
  end
end
