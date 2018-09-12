# frozen_string_literal: true

require 'test_helper'

class HabitsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'showHabitsTest',
                        email: 'showHabitsTest@showHabitsTest.com',
                        password: 'showHabitsTest123')
    @user2 = User.create(nickname: 'test_habit',
                         email: 'test_habit@test_habit.com',
                         password: 'test_habit1234')
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
    result = get "/me/habits/#{@individual_habit.id}?token=#{@user.id}"
    assert result == 200
  end

  test 'Get a non existent individual habit' do
    result = get "/me/habits/555?token=#{@user.id}"
    assert result == 400
  end

  test 'Get an individual habit from a non existing user id' do
    result = get "/me/habits/#{@individual_habit.id}?token=555"
    assert result == 403
  end

  test 'Get an individual habit from another user id' do
    result = get "/me/habits/#{@individual_habit.id}?token=#{@user2.id}"
    assert result == 400
  end
end
