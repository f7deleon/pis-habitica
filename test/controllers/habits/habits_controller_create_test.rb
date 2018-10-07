# frozen_string_literal: true

require 'test_helper'

class HabitsControllerCreateTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(
      nickname: 'Example',
      email: 'example@example.com',
      password: 'Example123'
    )

    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        'password': @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    @default_type = DefaultType.create(
      user_id: @user.id,
      name: 'Example',
      description: 'Example'
    )
    @default_type2 = DefaultType.create(
      user_id: @user.id,
      name: 'Example2',
      description: 'Example2'
    )
  end

  test 'should be valid' do
    assert @user.valid?
    assert @default_type.valid?
    assert @default_type2.valid?
  end
  test 'AltaHabito: should create habit' do
    post '/me/habits', headers: { 'Authorization': 'Bearer ' + @user_token }, params: {
      'data': {
        'type': 'habit',
        'attributes': { 'name': 'Example', 'description': 'Example', 'frequency': 1, 'difficulty': 1, 'privacy': 1 },
        'relationships': {
          'types': [
            { 'data': { 'id': @default_type.id, 'type': 'type' } },
            { 'data': { 'id': @default_type2.id, 'type': 'type' } }
          ]
        }
      }
    }
    expected = {
      'data': {
        'id': JSON.parse(response.body)['data']['id'], 'type': 'habit', 'attributes': {
          'name': 'Example', 'description': 'Example', 'difficulty': 1, 'privacy': 1, 'frequency': 1, 'count_track': 0
        }, 'relationships': {
          'types': {
            'data': [{ 'id': @default_type.id.to_s, 'type': 'type' }, { 'id': @default_type2.id.to_s, 'type': 'type' }]
          }
        }
      }
    }
    assert_equal 201, status # Created
    assert expected.to_json == response.body
  end
  test 'AltaHabito: User should exist' do
    post '/me/habits', headers: {
      'Authorization': 'Bearer asdasd'
    }, params: {
      'data': {
        'type': 'habit',
        'attributes': {
          'name': 'Example',
          'description': 'Example',
          'frequency': 1,
          'difficulty': 1,
          'privacy': 1
        },
        'relationships': {
          'types': [
            { 'data': { 'id': @default_type.id, 'type': 'type' } },
            { 'data': { 'id': @default_type2.id, 'type': 'type' } }
          ]
        }
      }
    }
    assert_equal 401, status # Unauthorized
  end
  test 'AltaHabito: Type should exist' do
    post '/me/habits', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': {
        'type': 'habit',
        'attributes': {
          'name': 'Example',
          'description': 'Example',
          'frequency': 1,
          'difficulty': 1,
          'privacy': 1
        },
        'relationships': {
          'types': [
            { 'data': { 'id': 999_999_999, 'type': 'type' } }
          ]
        }
      }
    }
    assert_equal 404, status # Not Found
  end

  test 'AltaHabito: should have correct Format' do
    post '/me/habits', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': {
        'type': 'habit',
        'attributes': {
          'title': 'Example',
          'description': 'Example',
          'frequency': 1,
          'difficulty': 1,
          'privacy': 1
        },
        'relationships': {
          'types': [
            { 'data': { 'id': @default_type.id, 'type': 'type' } },
            { 'data': { 'id': @default_type2.id, 'type': 'type' } }
          ]
        }
      }
    }
    assert_equal 400, status # Bad Request
  end
  test 'AltaHabito: at least 1 type' do
    post '/me/habits', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': {
        'type': 'habit',
        'attributes': {
          'name': 'Example',
          'description': 'Example',
          'frequency': 1,
          'difficulty': 1,
          'privacy': 1
        },
        'relationships': {
          'types': []
        }
      }
    }
    assert_equal 400, status # Bad Request
  end
end
