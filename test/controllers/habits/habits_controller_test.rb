# frozen_string_literal: true

require 'test_helper'

class HabitsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'showHabitsTest',
                        email: 'showHabitsTest@showHabitsTest.com',
                        password: 'showHabitsTest123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        "password": @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    @user2 = User.create(nickname: 'test_habit',
                         email: 'test_habit@test_habit.com',
                         password: 'test_habit1234')
    post '/user_token', params: {
      'auth': {
        'email': @user2.email,
        "password": @user2.password
      }
    }
    @user2_token = JSON.parse(response.body)['jwt']

    @individual_habit = IndividualHabit.create(user_id: @user.id,
                                               name: 'showHabitsTest',
                                               description: 'showHabitsTest',
                                               difficulty: 3,
                                               privacy: 1,
                                               frequency: 1)
    @individual_habit = IndividualHabit.create(user_id: @user.id,
                                               name: 'showHabitsTest',
                                               description: 'showHabitsTest',
                                               difficulty: 3,
                                               privacy: 1,
                                               frequency: 1)
    @user.individual_habits << @individual_habit
  end

  ### Ver Habito
  test 'Get an existing individual habit' do
    result = get '/me/habits/' + @individual_habit.id.to_s, headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 200
  end

  test 'Get a non existent individual habit' do
    result = get '/me/habits/555', headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 404
  end

  test 'Get an individual habit from a non existing user id' do
    result = get "/me/habits/#{@individual_habit.id}", headers: { 'Authorization': 'Bearer faketoken' }
    assert result == 401
  end

  test 'Get habits paginated' do
    result = get '/me/habits?page=1', headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 200
    output = JSON.parse(response.body)
    assert output['data'].length == Habit.all.where(user_id: @user.id).length
  end

  test 'Get habits paginated empty' do
    result = get '/me/habits?page=100', headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 200
    output = JSON.parse(response.body)
    assert output['data'].empty?
  end
end
