# frozen_string_literal: true

require 'test_helper'

class HabitsControllerGroupDeleteTest < ActionDispatch::IntegrationTest
  def setup
    @user1 = User.create(nickname: 'Example1', email: 'example1@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user1.email,
        'password': @user1.password
      }
    }
    @user_token1 = JSON.parse(response.body)['jwt']
    @user2 = User.create(nickname: 'Example2', email: 'example2@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user2.email,
        'password': @user2.password
      }
    }
    @user_token2 = JSON.parse(response.body)['jwt']
    @user3 = User.create(nickname: 'Example3', email: 'example3@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user3.email,
        'password': @user3.password
      }
    }
    @user_token3 = JSON.parse(response.body)['jwt']
    @groupless_user = User.create(nickname: 'groupless_user', email: 'groupless@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @groupless_user.email,
        'password': @groupless_user.password
      }
    }
    @groupless_user_token = JSON.parse(response.body)['jwt']

    @group = Group.create(name: 'example', privacy: true)
    @membership1 = Membership.create(user_id: @user1.id, group_id: @group.id, admin: true)
    @membership2 = Membership.create(user_id: @user2.id, group_id: @group.id, admin: false)

    @group2 = Group.create(name: 'example', privacy: true)
    @membership3 = Membership.create(user_id: @user3.id, group_id: @group.id, admin: true)
    @membership4 = Membership.create(user_id: @user2.id, group_id: @group.id, admin: false)

    @habit = GroupHabit.create(
      group_id: @group.id,
      name: 'Example',
      description: 'Example',
      difficulty: 3,
      privacy: 1,
      frequency: 2,
      active: true,
      negative: false
    )
    @negative_habit = GroupHabit.create(
      group_id: @group.id,
      name: 'Example',
      description: 'Example',
      difficulty: 3,
      privacy: 1,
      frequency: 1,
      active: true,
      negative: true
    )
    @char = Character.create(name: 'Mago', description: I18n.t('mage_description'))
    req = {
      'data': {
        'id': @char.id.to_s,
        'type': 'characters',
        'attributes': { 'name': 'Mago', 'description': I18n.t('mage_description') }
      },
      'included': [{ 'type': 'date', 'attributes': { 'date': '2018-09-07T12:00:00Z' } }]
    }
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + @user_token1
    }, params: req
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + @user_token2
    }, params: req
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + @user_token3
    }, params: req
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + @groupless_user_token
    }, params: req
  end

  test 'should be valid' do
    assert @user1.valid?
    assert @user2.valid?
    assert @user3.valid?
    assert @groupless_user.valid?

    assert @group.valid?
    assert @group2.valid?

    assert @char.valid?

    assert @habit.valid?
    assert @negative_habit.valid?

    assert @membership1.valid?
    assert @membership2.valid?
    assert @membership3.valid?
    assert @membership4.valid?
  end

  test 'should delete habit' do
    patch '/me/groups/' + @group.id.to_s + '/habits/' + @habit.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user_token1
    }, params: {
      'data': {
        'type': 'habits',
        'attributes': {
          'active': 0
        }
      }
    }
    assert_equal 204, status # Not Content
  end
  test 'should be admin to delete' do
    patch '/me/groups/' + @group.id.to_s + '/habits/' + @habit.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user_token2
    }, params: {
      'data': {
        'type': 'habits',
        'attributes': {
          'active': 0
        }
      }
    }
    assert_equal 403, status # Forbidden
  end
  test 'habit should exist' do
    patch '/me/groups/' + @group.id.to_s + '/habits/123123123', headers: {
      'Authorization': 'Bearer ' + @user_token1
    }, params: {
      'data': {
        'type': 'habits',
        'attributes': {
          'active': 0
        }
      }
    }
    assert_equal 404, status # Not Found
  end
  test 'User should exist' do
    patch '/me/groups/' + @group.id.to_s + '/habits/' + @habit.id.to_s, headers: {
      'Authorization': 'Bearer asdasd'
    }, params: {
      'data': {
        'type': 'habits',
        'attributes': {
          'active': 0
        }
      }
    }
    assert_equal 401, status # Unauthorized
  end
  test 'User should belong to this group' do
    patch '/me/groups/' + @group.id.to_s + '/habits/' + @habit.id.to_s, headers: {
      'Authorization': 'Bearer ' + @groupless_user_token
    }, params: {
      'data': {
        'type': 'habits',
        'attributes': {
          'active': 0
        }
      }
    }
    assert_equal 404, status # Not Found
  end

  test 'Habit should be active' do
    @habit.active = false
    @habit.save
    patch '/me/groups/' + @group.id.to_s + '/habits/' + @habit.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user_token1
    }, params: {
      'data': {
        'type': 'habits',
        'attributes': {
          'active': 0
        }
      }
    }
    assert_equal 404, status # Bad Request
  end
  test 'should have correct Format' do
    patch '/me/groups/' + @group.id.to_s + '/habits/' + @habit.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user_token1
    }, params: {
      'data': {
        'type': 'habits',
        'asdsadqwe': {
          'active': 0
        }
      }
    }
    assert_equal 400, status # Bad Request
  end
end
