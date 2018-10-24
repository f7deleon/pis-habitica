# frozen_string_literal: true

require 'test_helper'

class FriendsControllerAcceptRequestTest < ActionDispatch::IntegrationTest
  def setup
    @sender = User.create(nickname: 'sender', email: 'sender@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @sender.email,
        'password': @sender.password
      }
    }
    @sender_token = JSON.parse(response.body)['jwt']
    @character = Character.create(name: 'Humano', description: 'Descripcion humano')
    @user_character = UserCharacter.create(user_id: @sender.id,
                                           character_id: @character.id,
                                           creation_date: '2018-09-07T12:00:00Z',
                                           is_alive: true)
    @sender.user_characters << @user_character

    @receiver = User.create(nickname: 'receiver', email: 'receiver@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @receiver.email,
        'password': @receiver.password
      }
    }
    @receiver_token = JSON.parse(response.body)['jwt']

    @request = Request.create(user_id: @sender.id, receiver_id: @receiver.id)
    @sender.requests_sent << @request
    @receiver.requests_received << @request

    FriendRequestNotification.create(user_id: @receiver.id, request_id: @request.id)

    @expected = {
      'data': {
        'id': @sender.id.to_s,
        'type': 'friend',
        'attributes': {  'nickname': @sender.nickname,
                         'level': @sender.level },
        'relationships': { 'character': { 'data': { 'id': @character.id.to_s, 'type': 'character' } } }
      }
    }
  end

  test 'should be valid' do
    assert @sender.valid?
    assert @receiver.valid?
    assert @request.valid?
    assert @character.valid?
    assert @user_character.valid?
  end

  test 'AceptarAmistad: should accept friend request' do
    request_id = @request.id
    post '/me/friends/', headers: {
      'Authorization': 'Bearer ' + @receiver_token
    }, params: {
      'data': {
        'id': @request.id,
        'type': 'request',
        'relationships': { 'user': { 'data': { 'id': @sender.id, 'type': 'user' } } }
      }
    }
    assert_equal 201, status # Created
    assert @expected.to_json == response.body
    # Request is deleted
    assert_not Notification.find_by(request_id: request_id)
    assert_not Request.find_by(user_id: @sender.id, receiver_id: @receiver.id)
    assert_not @sender.requests_sent.find_by(user_id: @sender.id, receiver_id: @receiver.id)
    assert_not @receiver.requests_received.find_by(user_id: @sender.id, receiver_id: @receiver.id)
    # Friendship is added
    assert Friendship.find_by(user_id: @sender.id, friend_id: @receiver.id)
    assert Friendship.find_by(user_id: @receiver.id, friend_id: @sender.id)
    assert @sender.friendships.find_by(friend_id: @receiver)
    assert @receiver.friendships.find_by(friend_id: @sender)
    assert @sender.friends.find_by(id: @receiver.id)
    assert @receiver.friends.find_by(id: @sender.id)
    # Notification is created
    assert @sender.notifications.find_by(sender_id: @receiver.id)
  end
  test 'AceptarAmistad: receiver should exist' do
    post '/me/friends/', headers: {
      'Authorization': 'Bearer asdasdasd'
    }, params: {
      'data': {
        'id': @request.id,
        'type': 'request',
        'relationships': { 'user': { 'data': { 'id': @sender.id, 'type': 'user' } } }
      }
    }
    assert_equal 401, status # Unauthorized
  end
  test 'AceptarAmistad: request should exist' do
    post '/me/friends/', headers: {
      'Authorization': 'Bearer ' + @receiver_token
    }, params: {
      'data': {
        'id': '123123123',
        'type': 'request',
        'relationships': { 'user': { 'data': { 'id': @sender.id, 'type': 'user' } } }
      }
    }
    assert_equal 404, status # Not Found
  end
  test 'AceptarAmistad: you should not be the sender and receiver of the request' do
    # Observacion: Esta request es invalida.
    self_request = Request.create(user_id: @receiver.id, receiver_id: @receiver.id)
    @receiver.requests_sent << self_request
    @receiver.requests_received << self_request
    post '/me/friends/', headers: {
      'Authorization': 'Bearer ' + @receiver_token
    }, params: {
      'data': {
        'id': self_request.id,
        'type': 'request',
        'relationships': { 'user': { 'data': { 'id': @sender.id, 'type': 'user' } } }
      }
    }
    assert_equal 409, status # Conflict
  end
  test 'AceptarAmistad: sender should not be your friend' do
    Friendship.create(user_id: @sender.id, friend_id: @receiver.id)
    post '/me/friends/', headers: {
      'Authorization': 'Bearer ' + @receiver_token
    }, params: {
      'data': {
        'id': @request.id,
        'type': 'request',
        'relationships': { 'user': { 'data': { 'id': @sender.id, 'type': 'user' } } }
      }
    }
    assert_equal 409, status # Conflict
  end
  test 'AceptarAmistad: params should be valid' do
    post '/me/friends/', headers: {
      'Authorization': 'Bearer ' + @receiver_token
    }, params: {
      'data': {
        'idasd': @request.id,
        'type': 'request',
        'relationships': { 'user': { 'data': { 'id': @sender.id, 'type': 'user' } } }
      }
    }
    assert_equal 400, status # Bad Request
  end
end
