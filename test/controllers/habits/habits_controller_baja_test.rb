# frozen_string_literal: true

require 'test_helper'

class HabitsControllerBajaTest < ActionDispatch::IntegrationTest
  def setup
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
    @user2_token = JSON.parse(response.body)['jwt']

    @individual_type = IndividualType.create(user_id: @user.id, name: 'Example', description: 'Example')
    @individual_habit = IndividualHabit.create(
      user_id: @user.id,
      name: 'Example',
      description: 'Example',
      difficulty: 3,
      privacy: 1,
      frequency: 1,
      active: true
    )

    @user.individual_habits << @individual_habit

    @individual_habit_has_type = IndividualHabitHasType.create(
      habit_id: @individual_habit.id,
      type_id: @individual_type.id
    )

    @individual_habit.individual_habit_has_types << @individual_habit_has_type
    @individual_type.individual_habit_has_types << @individual_habit_has_type
  end

  test 'should be valid' do
    assert @user.valid?
    assert @individual_type.valid?
    assert @individual_habit.valid?
    assert @individual_habit_has_type.valid?
  end
  test 'BajaHabito: should delete habit' do
    patch '/habits/' + @individual_habit.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user_token
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
  test 'BajaHabito: habit should exist' do
    patch '/habits/9090999', headers: {
      'Authorization': 'Bearer ' + @user_token
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
  test 'BajaHabito: User should exist' do
    patch '/habits/' + @individual_habit.id.to_s, headers: {
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
  test 'BajaHabito: User should have this habit' do
    patch '/habits/' + @individual_habit.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user2_token
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

  test 'BajaHabito: Habit should be active' do
    @individual_habit.active = false
    @individual_habit.save
    patch '/habits/' + @individual_habit.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user_token
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
  test 'BajaHabito: should have correct Format' do
    patch '/habits/' + @individual_habit.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user_token
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
