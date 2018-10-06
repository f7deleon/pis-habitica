# frozen_string_literal: true

require 'test_helper'

class HabitsControllerUntoTest < ActionDispatch::IntegrationTest
  def setup
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
    @track_individual_habit_to_return = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.zone.now
    )
    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.zone.now
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
    @expected = TrackIndividualHabitSerializer.new([@track_individual_habit_to_return])

    @expected_empty_return = TrackIndividualHabitSerializer.new([])
  end
  test 'undo_habit' do
    put '/me/habits/' + @individual_habit.id.to_s + '/undo', headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    assert @expected.to_json == response.body
  end
  test 'undo_empty_habit' do
    put '/me/habits/' + @individual_habit_empty.id.to_s + '/undo', headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    assert @expected_empty_return.to_json == response.body
  end
end
