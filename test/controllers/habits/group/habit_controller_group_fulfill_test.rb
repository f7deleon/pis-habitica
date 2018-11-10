# frozen_string_literal: true

require 'test_helper'

class HabitsControllerGroupFulfillTest < ActionDispatch::IntegrationTest
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

  test 'should track habit' do
    post '/me/groups/' + @group.id.to_s + '/habits/' + @habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token1
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:27+00:00' } } }
    expected = {
      'data': {
        'id': JSON.parse(response.body)['data']['id'],
        'type': 'track',
        'attributes': {
          'max_health': User.find_by_id(@user1.id).max_health,
          'health_difference': 0, # Is at full health
          'max_experience': User.find_by_id(@user1.id).max_experience,
          'experience_difference': @habit.increment_of_experience(@user1),
          'score_difference': @habit.score_difference
        },
        'relationships': { 'group_habit': { 'data': { 'id': @habit.id.to_s, 'type': 'group_habit' } } }
      }
    }
    assert expected.to_json == response.body
    assert_equal 201, status # Created
    assert TrackGroupHabit.find_by(id: JSON.parse(response.body)['data']['id'])
    assert @user1.track_group_habits.find_by(id: JSON.parse(response.body)['data']['id'])
    assert @habit.track_group_habits.find_by(id: JSON.parse(response.body)['data']['id'])
  end

  test 'both users should be able to fulfill daily habit' do
    post '/me/groups/' + @group.id.to_s + '/habits/' + @habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token1
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:27+00:00' } } }
    post '/me/groups/' + @group.id.to_s + '/habits/' + @habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token2
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:27+00:00' } } }
    expected = {
      'data': {
        'id': JSON.parse(response.body)['data']['id'],
        'type': 'track',
        'attributes': {
          'max_health': User.find_by_id(@user2.id).max_health,
          'health_difference': 0, # Is at full health
          'max_experience': User.find_by_id(@user2.id).max_experience,
          'experience_difference': @habit.increment_of_experience(@user2),
          'score_difference': @habit.score_difference
        },
        'relationships': { 'group_habit': { 'data': { 'id': @habit.id.to_s, 'type': 'group_habit' } } }
      }
    }
    assert expected.to_json == response.body
    assert_equal 201, status # Created
    assert TrackGroupHabit.find_by(id: JSON.parse(response.body)['data']['id'])
    assert @user2.track_group_habits.find_by(id: JSON.parse(response.body)['data']['id'])
    assert @habit.track_group_habits.find_by(id: JSON.parse(response.body)['data']['id'])
  end

  test 'If Habit frequency is daily habit must not have been fulfilled today by the same user' do
    post '/me/groups/' + @group.id.to_s + '/habits/' + @habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token1
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:27+00:00' } } }
    post '/me/groups/' + @group.id.to_s + '/habits/' + @habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token1
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:27+00:00' } } }
    assert_equal 409, status # Conflict
  end

  test 'Negative Habit: should track habit' do
    post '/me/groups/' + @group.id.to_s + '/habits/' + @negative_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token1
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:27+00:00' } } }
    expected = {
      'data': {
        'id': JSON.parse(response.body)['data']['id'],
        'type': 'track',
        'attributes': {
          'max_health': User.find_by_id(@user1.id).max_health,
          'health_difference': @negative_habit.decrement_of_health(@user1), # Is at full health
          'max_experience': User.find_by_id(@user1.id).max_experience,
          'score_difference': @negative_habit.score_difference
        },
        'relationships': { 'group_habit': { 'data': { 'id': @negative_habit.id.to_s, 'type': 'group_habit' } } }
      }
    }
    assert expected.to_json == response.body
    assert_equal 201, status # Created
    assert TrackGroupHabit.find_by(id: JSON.parse(response.body)['data']['id'])
    assert @user1.track_group_habits.find_by(id: JSON.parse(response.body)['data']['id'])
    assert @negative_habit.track_group_habits.find_by(id: JSON.parse(response.body)['data']['id'])
  end

  test 'Negative Habit: both users should be able to fulfill daily habit' do
    post '/me/groups/' + @group.id.to_s + '/habits/' + @negative_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token1
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:27+00:00' } } }
    post '/me/groups/' + @group.id.to_s + '/habits/' + @negative_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token2
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:27+00:00' } } }
    expected = {
      'data': {
        'id': JSON.parse(response.body)['data']['id'],
        'type': 'track',
        'attributes': {
          'max_health': User.find_by_id(@user2.id).max_health,
          'health_difference': @negative_habit.decrement_of_health(@user2),
          'max_experience': User.find_by_id(@user2.id).max_experience,
          'score_difference': @negative_habit.score_difference
        },
        'relationships': { 'group_habit': { 'data': { 'id': @negative_habit.id.to_s, 'type': 'group_habit' } } }
      }
    }
    assert expected.to_json == response.body
    assert_equal 201, status # Created
    assert TrackGroupHabit.find_by(id: JSON.parse(response.body)['data']['id'])
    assert @user2.track_group_habits.find_by(id: JSON.parse(response.body)['data']['id'])
    assert @negative_habit.track_group_habits.find_by(id: JSON.parse(response.body)['data']['id'])
  end

  test 'user has to be a member from the group' do
    post '/me/groups/' + @group.id.to_s + '/habits/' + @habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @groupless_user_token
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:27+00:00' } } }
    assert_equal 404, status # Not Found
  end

  test 'Group should exist' do
    post '/me/groups/999999999/habits/' + @habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token1
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:27+00:00' } } }
    assert_equal 404, status # Not Found
  end

  test 'Habit should exist' do
    post '/me/groups/' + @group.id.to_s + '/habits/999999999/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token1
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:27+00:00' } } }
    assert_equal 404, status # Not Found
  end

  test 'Habit should belong to group' do
    post '/me/groups/' + @group2.id.to_s + '/habits/' + @habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token1
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:27+00:00' } } }
    assert_equal 404, status # Not Found
  end

  test 'token should be valid' do
    post '/me/groups/' + @group.id.to_s + '/habits/' + @habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer asdasd'
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:27+00:00' } } }
    assert_equal 401, status # Unauthorized
  end

  test 'Date should be in ISO 8601' do
    post '/me/groups/' + @group.id.to_s + '/habits/' + @habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token1
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': Time.now.rfc2822 } } }
    assert_equal 400, status # Bad Request
  end

  test 'Request should have correct Format' do
    post '/me/groups/' + @group.id.to_s + '/habits/' + @habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token1
    }, params: { 'data': { 'type': 'date', 'attributes': { 'qweqweq': '2018-09-05T21:39:27+00:00' } } }
    assert_equal 400, status # Bad Request
  end
end
