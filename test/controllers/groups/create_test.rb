# frozen_string_literal: true

require 'test_helper'

class GroupCreateControllerTest < ActionDispatch::IntegrationTest
  def params_correct
    {

      'data': {
        'type': 'group',
        'attributes': {
          'name': 'El Barzon',
          'description': 'Directo al barro',
          'privacy': 0

        },
        'relationships': {
          'members': {
            'data': [
              {
                'id': @member1.id.to_s,
                'type': 'user'
              },
              {
                'id': @member2.id.to_s,
                'type': 'user'
              }
            ]
          }
        }
      },
      'included': [
        {
          'id': @member1.id.to_s,
          'type': 'user',
          'attributes': {
            'nickname': 'Demogorgon',
            'level': 4
          },
          'relationships': {
            'character': {
              'data': {
                'id': '4',
                'type': 'character'
              }
            }
          }
        },
        {
          'id': @member2.id.to_s,
          'type': 'user',
          'attributes': {
            'nickname': 'Feli',
            'level': 1
          },
          'relationships': {
            'character': {
              'data': {
                'id': '1',
                'type': 'character'
              }
            }
          }
        }
      ]
    }
  end

  def expected_correct
    {
      'data': {
        'id': JSON.parse(response.body)['data']['id'],
        'type': 'group',
        'attributes': {
          'name': 'El Barzon',
          'description': 'Directo al barro',
          'privacy': false,
          'group_status': 3
        },
        'relationships': {
          'members': {
            'data': [
              {
                'id': @user_admin.id.to_s,
                'type': 'user'
              },
              {
                'id': @member1.id.to_s,
                'type': 'user'
              },
              {
                'id': @member2.id.to_s,
                'type': 'user'
              }
            ]
          },
          'admin': {
            'data': {
              'id': @user_admin.id.to_s,
              'type': 'user'
            }
          },
          'group_habits': {
            'data': []
          },
          'group_types': {
            'data': []
          }
        }
      },
      'included': [
        {
          'id': @user_admin.id.to_s,
          'type': 'user',
          'attributes': {
            'nickname': 'Example',
            'level': 1
          },
          'relationships': {
            'character': {
              'data': {
                'id': @character1.id.to_s,
                'type': 'character'
              }
            }
          }
        },
        {
          'id': @member1.id.to_s,
          'type': 'user',
          'attributes': {
            'nickname': 'member1',
            'level': 1
          },
          'relationships': {
            'character': {
              'data': {
                'id': @character.id.to_s,
                'type': 'character'
              }
            }
          }
        },
        {
          'id': @member2.id.to_s,
          'type': 'user',
          'attributes': {
            'nickname': 'member2',
            'level': 1
          },
          'relationships': {
            'character': {
              'data': {
                'id': @character1.id.to_s,
                'type': 'character'
              }
            }
          }
        }
      ]
    }
  end

  def param_not_friend
    {

      'data': {
        'type': 'group',
        'attributes': {
          'name': 'El Barzon',
          'description': 'Directo al barro',
          'privacy': 0
        },
        'relationships': {
          'members': {
            'data': [
              {
                'id': @nor_friend.id.to_s,
                'type': 'user'
              }
            ]
          }
        }
      }
    }
  end

  def param_not_user
    {

      'data': {
        'type': 'group',
        'attributes': {
          'name': 'El Barzon',
          'description': 'Directo al barro',
          'privacy': 0

        },
        'relationships': {
          'members': {
            'data': [
              {
                'id': -1.to_s,
                'type': 'user'
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

    # Characters
    @character = Character.create(name: 'Humano', description: 'Descripcion humano')
    @character1 = Character.create(name: 'Brujo', description: 'Descripcion brujo')
    @member1.add_character(@character.id, '2018-09-07T12:00:00Z')
    @member2.add_character(@character1.id, '2018-09-07T12:00:00Z')
    @user_admin.add_character(@character1.id, '2018-09-07T12:00:00Z')
  end
  test 'CreateGroup correct form' do
    post '/me/groups/', headers: { 'Authorization': 'Bearer ' + @user_token }, params: params_correct
    expected = expected_correct
    assert response.body == expected.to_json
  end
  test 'CreateGroup not Exist' do
    post '/me/groups/', headers: { 'Authorization': 'Bearer ' + @user_token }, params:
    param_not_user
    expected = {
      'errors': [
        {
          'status': '404',
          'title': 'Bad request',
          'message': 'Members do not exist'
        }
      ]
    }
    assert response.body == expected.to_json
  end
end
