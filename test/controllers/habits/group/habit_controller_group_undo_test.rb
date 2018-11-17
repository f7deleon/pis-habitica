# frozen_string_literal: true

require 'test_helper'

class HabitsControllerGroupUndoTest < ActionDispatch::IntegrationTest
  def setup
    # User
    @user = User.create(nickname: 'Example', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        'password': @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']
    @user2 = User.create(nickname: 'Example2', email: 'example2@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user2.email,
        'password': @user2.password
      }
    }
    @group = Group.create(name: 'example', privacy: true)
    @membership1 = Membership.create(user_id: @user.id, group_id: @group.id, admin: true)
    @membership2 = Membership.create(user_id: @user2.id, group_id: @group.id, admin: false)

    @group_habit = GroupHabit.create(
      group_id: @group.id,
      name: 'Example',
      description: 'Example',
      difficulty: 3,
      privacy: 1,
      frequency: 1,
      active: true
    )
    @group_habit_empty = GroupHabit.create(
      group_id: @group.id,
      name: 'Example2',
      description: 'Example2',
      difficulty: 3,
      privacy: 1,
      frequency: 1,
      active: true
    )
    @group_habit_negative = GroupHabit.create(
      group_id: @group.id,
      name: 'Example',
      description: 'Example',
      difficulty: 3,
      privacy: 1,
      frequency: 1,
      active: true,
      negative: true
    )

    # If user has no character alive it won't let fulfill habit
    @char = Character.create(name: 'Mago', description: I18n.t('mage_description'))
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': {
        'id': @char.id.to_s,
        'type': 'characters',
        'attributes': { 'name': 'Mago', 'description': I18n.t('mage_description') }
      },
      'included': [{ 'type': 'date', 'attributes': { 'date': '2018-09-07T12:00:00Z' } }]
    }
  end

  test 'is valid' do
    assert @user.valid?
    assert @user2.valid?
    assert @group.valid?
    assert @membership1.valid?
    assert @membership2.valid?
    assert @group_habit.valid?
    assert @group_habit_empty.valid?
    assert @group_habit_negative.valid?
    assert @char.valid?
  end

  test 'undo_habit' do
    user = User.find(@user.id)
    user.health = 50
    user.save
    post '/me/groups/' + @group.id.to_s + '/habits/' + @group_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': { 'type': 'date', 'attributes': { 'date': Time.zone.now.iso8601 } }
    }
    delete '/me/groups/' + @group.id.to_s + '/habits/' + @group_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    expected = {
      'data': {
        'id': @group_habit.id.to_s,
        'type': 'track',
        'attributes': {
          'max_health': User.find_by_id(@user.id).max_health,
          'health_difference': -@group_habit.increment_of_health(@user),
          'max_experience': User.find_by_id(@user.id).max_experience,
          'experience_difference': -@group_habit.increment_of_experience(@user)
        }
      }
    }
    assert expected.to_json == response.body
    assert_equal 202, status # Accepted
  end
  test 'undo_negative_habit' do
    post '/me/groups/' + @group.id.to_s + '/habits/' + @group_habit_negative.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': Time.zone.now.iso8601 } } }
    delete '/me/groups/' + @group.id.to_s + '/habits/' + @group_habit_negative.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    expected = {
      'data': {
        'id': @group_habit_negative.id.to_s,
        'type': 'track',
        'attributes': {
          'max_health': User.find_by_id(@user.id).max_health,
          'health_difference': -@group_habit_negative.decrement_of_health(@user),
          'max_experience': User.find_by_id(@user.id).max_experience,
          'experience_difference': 0
        }
      }
    }
    assert expected.to_json == response.body
    assert_equal 202, status # Accepted
  end

  test 'undo_empty_habit' do
    delete '/me/groups/' + @group.id.to_s + '/habits/' + @group_habit_empty.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    assert_equal 404, status # Not Found
  end

  test 'undo_habit level up' do
    @user.experience = @user.max_experience - 1
    User.find(@user.id).update_column(:experience, @user.experience)

    post '/me/groups/' + @group.id.to_s + '/habits/' + @group_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': Time.zone.now.iso8601 } } }

    delete '/me/groups/' + @group.id.to_s + '/habits/' + @group_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    expected = {
      'data': {
        'id': @group_habit.id.to_s, 'type': 'track',
        'attributes': {
          'max_health': User.find_by_id(@user.id).max_health,
          'health_difference': 0,
          'max_experience': User.find_by_id(@user.id).max_experience,
          'experience_difference': -(@group_habit.increment_of_experience(User.find(@user.id)) - 1)
        }
      }
    }
    assert expected.to_json == response.body
    assert_equal 202, status # Accepted

    # check that user's experience has decreased but not health
    get '/me', headers: { 'Authorization': 'Bearer ' + @user_token.to_s }
    assert_equal JSON.parse(response.body)['data']['attributes']['experience'], -1
    assert JSON.parse(response.body)['data']['attributes']['health'].eql? User.find_by_id(@user.id).max_health
  end

  test 'undo_habit without fulfill in same day' do
    post '/me/groups/' + @group.id.to_s + '/habits/' + @group_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': {
        'type': 'date',
        'attributes': {
          'date': '2018-09-05T21:39:29+00:00'
        }
      }
    }
    delete '/me/groups/' + @group.id.to_s + '/habits/' + @group_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    expected = {
      "errors": [
        { "status": 'not_found', "title": 'Not found', "message": 'This habit has not been fulfilled today' }
      ]
    }
    assert expected.to_json == response.body
    assert_equal 404, status
  end

  test 'undo_habit without alive character' do
    character = User.find(@user.id).user_characters.find_by(is_alive: true)
    character.update_column(:is_alive, false)

    delete '/me/groups/' + @group.id.to_s + '/habits/' + @group_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }

    expected = { "errors":
      [
        { "status": '404', "title": 'Not found', "message": 'This user has not created a character yet' }
      ] }
    assert expected.to_json == response.body
    assert_equal 404, status # Accepted
  end
end
