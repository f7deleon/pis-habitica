# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'Example', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        "password": @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    @user1 = User.create(nickname: 'Example2', email: 'example2@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user1.email,
        "password": @user1.password
      }
    }
    @user1_token = JSON.parse(response.body)['jwt']

    @user2 = User.create(nickname: 'Example3', email: 'example3@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user2.email,
        'password': @user2.password
      }
    }

    @user2_token = JSON.parse(response.body)['jwt']

    @user3 = User.create(nickname: 'Ozuna', email: 'latino@negritojosclaro.com', password: 'dontcare')
    post '/user_token', params: {
      'auth': {
        'email': @user3.email,
        'password': @user3.password
      }
    }

    Request.create(user_id: @user3.id, receiver_id: @user.id)

    @user3_token = JSON.parse(response.body)['jwt']
    @user4 = User.create(nickname: 'barack', email: 'notpresidentanymore@usa.com', password: 'dontcare23')
    @user5 = User.create(nickname: 'aaaaabaracaaaaa', email: 'notpresidentanymore1@usa.com', password: 'dontcare1')
    post '/user_token', params: {
      'auth': {
        'email': @user5.email,
        'password': @user5.password
      }
    }
    @user5_token = JSON.parse(response.body)['jwt']

    ### friends
    @friendship = Friendship.create(user_id: @user1.id, friend_id: @user2.id)

    @my_friends = UserInfoSerializer.new([@user2], params: { current_user: @user1 }).serialized_json

    ### Characters creation
    @character = Character.create(name: 'Humano',
                                  description: 'Descripcion humano')
    @character1 = Character.create(name: 'Brujo',
                                   description: 'Descripcion brujo')

    ### Parameters for requests
    @parameters = { "data": { "id": @character.id.to_s,
                              "type": 'characters',
                              "attributes": { "name": 'Mago',
                                              "description": 'Una descripcion de mago' } },
                    "included": [{ "type": 'date',
                                   "attributes": { "date": '2018-09-07T12:00:00Z' } }] }
    @parameters2 = { "data": { "id": @character1.id.to_s,
                               "type": 'characters',
                               "attributes": { "name": 'Mago',
                                               "description": 'Una descripcion de mago' } },
                     "included": [{ "type": 'date',
                                    "attributes": { "date": '2018-09-07T12:00:00Z' } }] }

    # Add character to user
    @user_character = UserCharacter.create(user_id: @user1.id,
                                           character_id: @character.id,
                                           creation_date: '2018-09-07T12:00:00Z',
                                           is_alive: true)

    @user1.user_characters << @user_character

    @user_character2 = UserCharacter.create(user_id: @user4.id,
                                            character_id: @character1.id,
                                            creation_date: '2018-09-03T12:00:00Z',
                                            is_alive: true)
    @user4.user_characters << @user_character2

    # Add habits to user
    @individual_habit = IndividualHabit.create(
      user_id: @user1.id,
      name: 'Example',
      description: 'Example desc',
      difficulty: 3,
      privacy: 1,
      frequency: 1,
      active: true
    )

    @individual_habit2 = IndividualHabit.create(
      user_id: @user1.id,
      name: 'Example2',
      description: 'Example2 desc',
      difficulty: 2,
      privacy: 2,
      frequency: 2,
      active: true
    )

    @individual_habit3 = IndividualHabit.create(
      user_id: @user1.id,
      name: 'Example3',
      description: 'Example3 desc',
      difficulty: 2,
      privacy: 3,
      frequency: 2,
      active: true
    )
    @individual_type = IndividualType.create(user_id: @user1.id, name: 'Example_seed', description: 'Example_seed')
    @habit_type = IndividualHabitHasType.create(habit_id: @individual_habit.id, type_id: @individual_type.id)

    # groups for testing
    @group = Group.create(name: 'Propio', description: 'Propio description', privacy: false)
    @group1 = Group.create(name: 'Propio1', description: 'Propio1 description', privacy: false)
    @group2_private = Group.create(name: 'Propio2', description: 'Propio2 description', privacy: true)
    Membership.create(user_id: @user.id, group_id: @group.id, admin: false)
    Membership.create(user_id: @user.id, group_id: @group1.id, admin: true)
    Membership.create(user_id: @user4.id, group_id: @group.id, admin: true)
    Membership.create(user_id: @user3.id, group_id: @group2_private.id, admin: true)
  end

  # Alta Personaje
  test 'AltaPersonaje: add character id 4 to user
                        id 1 user already have an is_alive character' do
    url = '/me/characters'
    result0 = post url, headers: { 'Authorization': 'Bearer ' + @user_token },
                        params: @parameters
    assert result0 == 201 # :created
    result = post url, headers: { 'Authorization': 'Bearer ' + @user_token },
                       params: @parameters2
    assert result == 409 # Conflict
  end

  test 'AltaPersonaje:  request without jwt' do
    result = post '/me/characters', params: @parameters
    assert result == 401 # :forbidden
  end

  test 'AltaPersonaje: char_id do not exists' do
    parameters = { "data": { "id": '300',
                             "type": 'characters',
                             "attributes": { "name": 'Mago',
                                             "description": 'Una descripcion de mago' } },
                   "included": [{ "type": 'date',
                                  "attributes": { "date": '2018-09-07T12:00:00Z' } }] }
    result = post '/me/characters', headers: { 'Authorization': 'Bearer ' + @user_token },
                                    params: parameters
    assert result == 404 # Not Found
  end

  test 'AltaPersonaje: wrong date format' do
    parameters = { "data": { "id": '3',
                             "type": 'characters',
                             "attributes": { "name": 'Mago',
                                             "description": 'Una descripcion de mago' } },
                   "included": [{ "type": 'date',
                                  "attributes": { "date": '2018-2:00:00Z' } }] }
    result = post '/me/characters', headers: { 'Authorization': 'Bearer ' + @user_token },
                                    params: parameters
    assert result == 400 # :bad_request
  end

  test 'Create user' do
    parameters = { "data": {
      "type": 'user',
      "attributes": {
        "nickname": 'Pai',
        "email": 'pai@habitica.com',
        "password": '12345678'
      }
    } }

    result = post '/users', params: parameters
    user = User.last

    assert result == 201

    result_json = JSON.parse(response.body)
    assert user.id == result_json['data']['id'].to_i
  end

  test 'Bad request user' do
    url = '/users'

    parameters = { "data": {
      "type": 'user',
      "attributes": {
        "nickname": 'Pai',
        "email": 'pai@habitica.com'
      }
    } }

    result = post url, params: parameters
    assert result == 400
  end

  test 'Ver mis amigos: OK' do
    result = get '/me/friends', headers: { 'Authorization': 'Bearer ' + @user1_token }
    assert result == 200
    assert_equal response.body, @my_friends
  end

  test 'Ver mis amigos: dont attach Authorization token (unauthorized returned)' do
    result = get '/me/friends'
    assert result == 401
  end

  test 'Ver perfil: user with 2 groups' do
    get '/users/' + @user.id.to_s, headers: { 'Authorization': 'Bearer ' + @user5_token.to_s }
    assert_equal 200, status
    body = JSON.parse(response.body)
    assert body['data']['relationships']['groups']['data'].length.eql? 2
  end

  test 'Ver perfil: user with 1 group' do
    get '/users/' + @user4.id.to_s, headers: { 'Authorization': 'Bearer ' + @user5_token.to_s }
    assert_equal 200, status
    body = JSON.parse(response.body)
    assert body['data']['relationships']['groups']['data'].length.eql? 1
  end

  test 'Ver perfil: user without groups' do
    get '/users/' + @user2.id.to_s, headers: { 'Authorization': 'Bearer ' + @user5_token.to_s }
    assert_equal 200, status
    body = JSON.parse(response.body)
    assert body['data']['relationships']['groups']['data'].length.eql? 0
  end

  test 'Ver perfil: user5 wants to see private group of user3, sees zero' do
    get '/users/' + @user3.id.to_s, headers: { 'Authorization': 'Bearer ' + @user5_token.to_s }
    assert_equal 200, status
    body = JSON.parse(response.body)
    assert body['data']['relationships']['groups']['data'].length.eql? 0
  end

  test 'Ver perfil: user5 is added to user2 group and now he can see the group besides it is private' do
    Membership.create(user_id: @user5.id, group_id: @group2_private.id, admin: false)
    get '/users/' + @user3.id.to_s, headers: { 'Authorization': 'Bearer ' + @user5_token.to_s }
    assert_equal 200, status
    body = JSON.parse(response.body)
    assert body['data']['relationships']['groups']['data'].length.eql? 1
  end
end
