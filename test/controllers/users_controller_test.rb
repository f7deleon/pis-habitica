# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'Example', email: 'example@example.com', password: 'Example123')
    @user1 = User.create(nickname: 'Example2', email: 'example2@example.com', password: 'Example123')
    @user2 = User.create(nickname: 'Example12', email: 'example12@example.com', password: 'Example123')
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
    @user_character = UserCharacter.create(user_id: @user.id,
                                           character_id: @character.id,
                                           creation_date: '2018-09-07T12:00:00Z',
                                           is_alive: true)

    @user1.user_characters << @user_character

    # Add habits to user
    @individual_habit = IndividualHabit.create(
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
    @individual_type = IndividualType.create(user_id: @user1.id, name: 'Example_seed', description: 'Example_seed')
    @habit_type = IndividualHabitHasType.create(habit_id: @individual_habit.id, type_id: @individual_type.id)

    @user1.individual_types << @individual_type
    @individual_habit.individual_habit_has_types << @habit_type
    @individual_habit2.individual_habit_has_types << @habit_type
    @user1.individual_habits << @individual_habit
    @user1.individual_habits << @individual_habit2
  end

  test 'should be valid' do
    assert @user1.valid?
    assert @character.valid?
    assert @user_character.valid?
    assert @individual_type.valid?
    assert @habit_type.valid?
    assert @individual_habit.valid?
    assert @individual_habit2.valid?
  end

  test 'should get home' do
    get '/me/home?token=' + @user1.id.to_s, params: {
      "data": {
        "id": @user1.id.to_s,
        "type": 'users',
        "attributes": {
          "nickname": @user1.nickname
        },
        "relationships": {
          "character": {
            "data": {
              "type": 'characters',
              "id": @user1.user_characters.to_s
            }
          },
          "habits": @user1.individual_habits
        }
      }
    }
    assert_equal 200, status
  end

  test 'get home without alive character' do
    get '/me/home?token=' + @user2.id.to_s, params: {
      "errors": [
        {
          "status": 404,
          "code": 1,
          "title": 'No character',
          "detail": 'User has no character alive'
        }
      ]
    }
    assert_equal 404, status
  end

  # Alta Personaje
  test 'AltaPersonaje: add character id 4 to user
                        id 1 user already have an is_alive character' do
    url = '/me/characters?token=' + @user.id.to_s

    result0 = post url, params: @parameters
    assert result0 == 201 # :created
    result = post url, params: @parameters2
    assert result == 400 # :bad_request
  end

  test 'AltaPersonaje:  user id do not exists' do
    result = post '/me/characters?token=9999', params: @parameters
    assert result == 403 # :forbidden
  end

  test 'AltaPersonaje: char_id do not exists' do
    parameters = { "data": { "id": '300',
                             "type": 'characters',
                             "attributes": { "name": 'Mago',
                                             "description": 'Una descripcion de mago' } },
                   "included": [{ "type": 'date',
                                  "attributes": { "date": '2018-09-07T12:00:00Z' } }] }
    result = post '/me/characters?token=' + @user.id.to_s, params: parameters
    assert result == 400 # :bad_request
  end

  test 'AltaPersonaje: wrong date format' do
    parameters = { "data": { "id": '3',
                             "type": 'characters',
                             "attributes": { "name": 'Mago',
                                             "description": 'Una descripcion de mago' } },
                   "included": [{ "type": 'date',
                                  "attributes": { "date": '2018-2:00:00Z' } }] }
    result = post '/me/characters?token=' + @user.id.to_s, params: parameters
    assert result == 400 # :bad_request
  end
end
