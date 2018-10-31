# frozen_string_literal: true

require 'test_helper'

class GroupCreateControllerTest < ActionDispatch::IntegrationTest
  def params_correct
    {

      "data": {
        "type": 'group',
        "attributes": {
          "name": 'El Barzon',
          "description": 'Directo al barro',
          "privacy": 0
        },
        "relationships": {
          "members": {
            "data": [
              {
                "id": @member1.id.to_s,
                "type": 'user'
              },
              {
                "id": @member2.id.to_s,
                "type": 'user'
              },
              {
                "id": @member3.id.to_s,
                "type": 'user'
              },
              {
                "id": @member4.id.to_s,
                "type": 'user'
              }
            ]
          }
        }
      }
    }
  end

  def expected_correct
    {
      "data": {
        "id": JSON.parse(response.body)['data']['id'],
        "type": 'group',
        "attributes": {
          "name": 'El Barzon',
          "description": 'Directo al barro',
          "privacy": false
        },
        "relationships": {
          "members": {
            "data": [
              {
                "id": @member1.id.to_s,
                "type": 'user'
              },
              {
                "id": @member2.id.to_s,
                "type": 'user'
              },
              {
                "id": @member3.id.to_s,
                "type": 'user'
              },
              {
                "id": @member4.id.to_s,
                "type": 'user'
              }
            ]
          },
          "admin": {
            "data": {
              "id": @user_admin.id.to_s,
              "type": 'user'
            }
          },
          "group_habits": {
            "data": []

          }
        }
      }
    }
  end

  def param_not_friend
    {

      "data": {
        "type": 'group',
        "attributes": {
          "name": 'El Barzon',
          "description": 'Directo al barro',
          "privacy": 0
        },
        "relationships": {
          "members": {
            "data": [
              {
                "id": @nor_friend.id.to_s,
                "type": 'user'
              }
            ]
          }
        }
      }
    }
  end

  def param_not_user
    {

      "data": {
        "type": 'group',
        "attributes": {
          "name": 'El Barzon',
          "description": 'Directo al barro',
          "privacy": 0
        },
        "relationships": {
          "members": {
            "data": [
              {
                "id": -1.to_s,
                "type": 'user'
              }
            ]
          }
        }
      }
    }
  end

  def setup
    @user_admin = User.create(nickname: 'Example', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user_admin.email,
        'password': @user_admin.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    # Members
    @member1 = User.create(nickname: 'member1', email: 'member1@member1.com', password: 'member1')
    @member2 = User.create(nickname: 'member2', email: 'member2@member2.com', password: 'member2')
    @member3 = User.create(nickname: 'member3', email: 'member3@member3.com', password: 'member3')
    @member4 = User.create(nickname: 'member4', email: 'member4@member4.com', password: 'member4')
    @nor_friend = User.create(nickname: 'nor_friend', email: 'nor_friend@nor_friend.com', password: 'nor_friend')

    # FriendShips
    Friendship.create(user_id: @user_admin.id, friend_id: @member1.id)
    Friendship.create(user_id: @user_admin.id, friend_id: @member2.id)
    Friendship.create(user_id: @user_admin.id, friend_id: @member3.id)
    Friendship.create(user_id: @user_admin.id, friend_id: @member4.id)
  end
  test 'CreateGroup correct form' do
    post '/me/groups/', headers: { 'Authorization': 'Bearer ' + @user_token }, params: params_correct
    expected = expected_correct
    puts expected.to_json
    puts response.body
    assert response.body == expected.to_json
  end
  test 'CreateGroup not friend' do
    post '/me/groups/', headers: { 'Authorization': 'Bearer ' + @user_token }, params:
    param_not_friend
    expected = {
      "errors": [
        {
          "status": '404',
          "title": 'Bad request',
          "message": 'Not all the members are your friend'
        }
      ]
    }
    assert response.body == expected.to_json
  end
  test 'CreateGroup not Exist' do
    post '/me/groups/', headers: { 'Authorization': 'Bearer ' + @user_token }, params:
    param_not_user
    expected = {
      "errors": [
        {
          "status": '404',
          "title": 'Bad request',
          "message": 'Members do not exist'
        }
      ]
    }
    assert response.body == expected.to_json
  end
end
