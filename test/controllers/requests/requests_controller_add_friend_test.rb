# frozen_string_literal: true

require 'test_helper'

class RequestsControllerAddFriendTest < ActionDispatch::IntegrationTest
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
  end

  test 'should be valid' do
    assert @sender.valid?
    assert @receiver.valid?
  end

  test 'AgregarAmigo: should send friend request' do
    post '/me/requests/', headers: {
      'Authorization': 'Bearer ' + @sender_token
    }, params: {
      'data': {
        'type': 'request',
        'relationships': { 'receiver': { 'data': { 'id': @receiver.id.to_s, 'type': 'user' } } }
      }
    }
    expected = {
      'data': {
        'id': JSON.parse(response.body)['data']['id'],
        'type': 'request',
        'relationships': {
          'sender': { 'data': { 'id': @sender.id.to_s, 'type': 'user' } },
          'receiver': { 'data': { 'id': @receiver.id.to_s, 'type': 'user' } }
        }
      }
    }
    assert_equal 201, status # Created
    assert expected.to_json == response.body
    assert_not Request.find_by(user_id: @sender.id, receiver_id: @receiver.id).nil?
    assert_not @sender.requests_sent.find_by(user_id: @sender.id, receiver_id: @receiver.id).nil?
    assert_not @receiver.requests_received.find_by(user_id: @sender.id, receiver_id: @receiver.id).nil?
    assert @receiver.notifications.find_by(request_id: JSON.parse(response.body)['data']['id'])
  end
  test 'AgregarAmigo: params should be valid' do
    post '/me/requests/', headers: {
      'Authorization': 'Bearer ' + @sender_token
    }, params: {
      'data': {
        'type': 'request',
        'relationships': {
          'receasdiver': { 'data': { 'id': @receiver.id.to_s, 'type': 'user' } }
        }
      }
    }
    assert_equal 400, status # Bad Request
  end
  test 'AgregarAmigo: sender should exist' do
    post '/me/requests/', headers: {
      'Authorization': 'Bearer asdasdasd'
    }, params: {
      'data': {
        'type': 'request',
        'relationships': {
          'receiver': { 'data': { 'id': @receiver.id.to_s, 'type': 'user' } }
        }
      }
    }
    assert_equal 401, status # Unauthorized
  end
  test 'AgregarAmigo: receiver should exist' do
    post '/me/requests/', headers: {
      'Authorization': 'Bearer ' + @sender_token
    }, params: {
      'data': {
        'type': 'request',
        'relationships': {
          'receiver': { 'data': { 'id': 'asdasdasdasd', 'type': 'user' } }
        }
      }
    }
    assert_equal 404, status # Not Found
  end
  test 'AgregarAmigo: receiver should not be you' do
    post '/me/requests/', headers: {
      'Authorization': 'Bearer ' + @sender_token
    }, params: {
      'data': {
        'type': 'request',
        'relationships': {
          'receiver': { 'data': { 'id': @sender.id.to_s, 'type': 'user' } }
        }
      }
    }
    assert_equal 409, status # Conflict
  end
  test 'AgregarAmigo: receiver should not be your friend' do
    @friendship = Friendship.create(user_id: @sender.id, friend_id: @receiver.id)
    @sender.friendships << @friendship
    post '/me/requests/', headers: {
      'Authorization': 'Bearer ' + @sender_token
    }, params: {
      'data': {
        'type': 'request',
        'relationships': {
          'receiver': { 'data': { 'id': @receiver.id.to_s, 'type': 'user' } }
        }
      }
    }
    assert_equal 409, status # Conflict
  end
  test 'AgregarAmigo: receiver should not have a pending request from you' do
    post '/me/requests/', headers: {
      'Authorization': 'Bearer ' + @sender_token
    }, params: {
      'data': {
        'type': 'request',
        'relationships': {
          'receiver': { 'data': { 'id': @receiver.id.to_s, 'type': 'user' } }
        }
      }
    }
    assert_equal 201, status # Created
    post '/me/requests/', headers: {
      'Authorization': 'Bearer ' + @sender_token
    }, params: {
      'data': {
        'type': 'request',
        'relationships': {
          'receiver': { 'data': { 'id': @receiver.id.to_s, 'type': 'user' } }
        }
      }
    }
    assert_equal 409, status # Conflict
  end
  test 'AgregarAmigo: you should not have a pending request from receiver' do
    post '/me/requests/', headers: {
      'Authorization': 'Bearer ' + @receiver_token
    }, params: {
      'data': {
        'type': 'request',
        'relationships': {
          'receiver': { 'data': { 'id': @sender.id.to_s, 'type': 'user' } }
        }
      }
    }
    assert_equal 201, status # Created
    post '/me/requests/', headers: {
      'Authorization': 'Bearer ' + @sender_token
    }, params: {
      'data': {
        'type': 'request',
        'relationships': {
          'receiver': { 'data': { 'id': @receiver.id.to_s, 'type': 'user' } }
        }
      }
    }
    assert_equal 409, status # Conflict
  end
end
