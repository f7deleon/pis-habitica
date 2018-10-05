# frozen_string_literal: true

require 'test_helper'

class UsersHomeControllerTest < ActionDispatch::IntegrationTest
  def setup
    # User
    @user = User.create(nickname: 'Example', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        "password": @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    # Add character to user
    @character = Character.create(name: 'Humano', description: 'Descripcion humano')
    @user_character = UserCharacter.create(user_id: @user.id,
                                           character_id: @character.id,
                                           creation_date: '2018-09-07T12:00:00Z',
                                           is_alive: true)

    @user.user_characters << @user_character

    # Add habit to user
    @individual_habit = IndividualHabit.create(
      user_id: @user.id,
      name: 'Correr',
      description: 'Correr seguido',
      difficulty: 3,
      privacy: 2,
      frequency: 2
    )

    @individual_type = IndividualType.create(user_id: @user.id, name: 'Ejercicio', description: 'Ejercicio seguido')
    @habit_type = IndividualHabitHasType.create(habit_id: @individual_habit.id, type_id: @individual_type.id)

    # User1
    @user1 = User.create(nickname: 'Example2', email: 'example2@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user1.email,
        "password": @user1.password
      }
    }
    @user1_token = JSON.parse(response.body)['jwt']

    @character1 = Character.create(name: 'Brujo',
                                   description: 'Descripcion brujo')

    # Add character to user1
    @user_character1 = UserCharacter.create(user_id: @user1.id,
                                            character_id: @character1.id,
                                            creation_date: '2018-09-07T12:00:00Z',
                                            is_alive: true)

    # Add habits to user
    @individual_habit1 = IndividualHabit.create(
      user_id: @user1.id,
      name: 'Example',
      description: 'Example desc',
      difficulty: 3,
      privacy: 1,
      frequency: 1
    )

    @individual_habit2 = IndividualHabit.create(
      user_id: @user1.id,
      name: 'Example2',
      description: 'Example2 desc',
      difficulty: 2,
      privacy: 2,
      frequency: 2
    )
    @individual_type1 = IndividualType.create(user_id: @user1.id, name: 'Example_seed', description: 'Example_seed')
    @habit_type1 = IndividualHabitHasType.create(habit_id: @individual_habit1.id, type_id: @individual_type1.id)

    # Add friends to user
    @user1.friendships.create(friend_id: @user3)

    # User 2
    @user2 = User.create(nickname: 'Example3', email: 'example3@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user2.email,
        'password': @user2.password
      }
    }
    @user2_token = JSON.parse(response.body)['jwt']

    # User 3
    @user3 = User.create(nickname: 'Ozuna', email: 'latino@negritojosclaro.com', password: 'dontcare')
    post '/user_token', params: {
      'auth': {
        'email': @user3.email,
        'password': @user3.password
      }
    }
    @user3_token = JSON.parse(response.body)['jwt']

    # Add character to user3
    @user_character3 = UserCharacter.create(user_id: @user3.id,
                                            character_id: @character.id,
                                            creation_date: '2018-09-07T12:00:00Z',
                                            is_alive: true)

    # Add notifications to user3
    @request = Request.create(receiver_id: @user3, user_id: @user1)
    @not = FriendRequestNotification.create(user_id: @user3, request_id: @request.id)

    # User 4
    @user4 = User.create(nickname: 'barack', email: 'notpresidentanymore@usa.com', password: 'dontcare23')
    post '/user_token', params: {
      'auth': {
        'email': @user4.email,
        "password": @user4.password
      }
    }
    @user4_token = JSON.parse(response.body)['jwt']

    # Add character to user4
    @user_character4 = UserCharacter.create(user_id: @user4.id,
                                            character_id: @character1.id,
                                            creation_date: '2018-09-07T12:00:00Z',
                                            is_alive: true)

    # Add friend to user4
    @user4.friendships.create(friend_id: @user2)
  end

  # Tests /me - Ir a home
  test 'Ir a home: user with all data' do
    get '/me', headers: { 'Authorization': 'Bearer ' + @user1_token.to_s }
    assert_equal 200, status
  end

  test 'Ir a home: user with no character alive' do
    get '/me', headers: { 'Authorization': 'Bearer ' + @user2_token.to_s }
    assert_equal 404, status
  end

  test 'Ir a home: user without habits' do
    get '/me', headers: { 'Authorization': 'Bearer ' + @user4_token.to_s }
    assert_equal 200, status
  end

  test 'Ir a home: user without friends' do
    get '/me', headers: { 'Authorization': 'Bearer ' + @user_token.to_s }
    assert_equal 200, status
  end

  test 'Ir a home: user with notifications' do
    get '/me', headers: { 'Authorization': 'Bearer ' + @user3_token.to_s }
    assert_equal 200, status
  end
end
