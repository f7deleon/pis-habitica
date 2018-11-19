# frozen_string_literal: true

require 'test_helper'

class HabitsControllerUndoTest < ActionDispatch::IntegrationTest
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
    @individual_habit = IndividualHabit.create(
      user_id: @user.id,
      name: 'Example',
      description: 'Example',
      difficulty: 3,
      privacy: 1,
      frequency: 1,
      active: true
    )
    @individual_habit_empty = IndividualHabit.create(
      user_id: @user.id,
      name: 'Example2',
      description: 'Example2',
      difficulty: 3,
      privacy: 1,
      frequency: 1,
      active: true
    )
    @individual_habit_negative = IndividualHabit.create(
      user_id: @user.id,
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
  test 'undo_habit' do
    user = User.find(@user.id)
    user.health = 50
    user.save
    post '/habits/' + @individual_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': { 'type': 'date', 'attributes': { 'date': Time.zone.now.iso8601 } }
    }
    delete '/habits/' + @individual_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    expected = {
      'data': {
        'id': @individual_habit.id.to_s,
        'type': 'track',
        'attributes': {
          'max_health': User.find_by_id(@user.id).max_health,
          'health_difference': -@individual_habit.increment_of_health(@user),
          'max_experience': User.find_by_id(@user.id).max_experience,
          'experience_difference': -@individual_habit.increment_of_experience(@user)
        }
      }
    }
    assert expected.to_json == response.body
    assert_equal 202, status # Accepted
  end
  test 'undo_negative_habit' do
    post '/habits/' + @individual_habit_negative.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': Time.zone.now.iso8601 } } }
    delete '/habits/' + @individual_habit_negative.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    expected = {
      'data': {
        'id': @individual_habit_negative.id.to_s,
        'type': 'track',
        'attributes': {
          'max_health': User.find_by_id(@user.id).max_health,
          'health_difference': -@individual_habit_negative.decrement_of_health(@user),
          'max_experience': User.find_by_id(@user.id).max_experience,
          'experience_difference': 0
        }
      }
    }
    assert expected.to_json == response.body
    assert_equal 202, status # Accepted
  end

  test 'undo_empty_habit' do
    delete '/habits/' + @individual_habit_empty.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    assert_equal 404, status # Not Found
  end

  test 'undo_habit level up' do
    @user.experience = @user.max_experience - 1
    User.find(@user.id).update_column(:experience, @user.experience)

    post '/habits/' + @individual_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': Time.zone.now.iso8601 } } }

    delete '/habits/' + @individual_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    expected = {
      'data': {
        'id': @individual_habit.id.to_s, 'type': 'track',
        'attributes': {
          'max_health': User.find_by_id(@user.id).max_health,
          'health_difference': 0,
          'max_experience': User.find_by_id(@user.id).max_experience,
          'experience_difference': -(@individual_habit.increment_of_experience(User.find(@user.id)) - 1)
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
    post '/habits/' + @individual_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': {
        'type': 'date',
        'attributes': {
          'date': '2018-09-05T21:39:29+00:00'
        }
      }
    }
    delete '/habits/' + @individual_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    expected = {
      "errors": [
        { "status": 404, "title": 'Not found', "message": 'This habit has not been fulfilled today' }
      ]
    }
    assert expected.to_json == response.body
    assert_equal 404, status
  end

  test 'undo_habit without alive character' do
    character = User.find(@user.id).user_characters.find_by(is_alive: true)
    character.update_column(:is_alive, false)

    delete '/habits/' + @individual_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }

    expected = { "errors":
      [
        { "status": 404, "title": 'Not found', "message": 'This user has not created a character yet' }
      ] }
    assert expected.to_json == response.body
    assert_equal 404, status # Accepted
  end
end
