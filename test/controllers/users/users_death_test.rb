# frozen_string_literal: true

require 'test_helper'

class UserDeathTest < ActionDispatch::IntegrationTest
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

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.zone.now
    )
  end

  test 'Test death function' do
    @user.death
    get '/habits/' + @individual_habit.id.to_s, headers: { 'Authorization': 'Bearer ' + @user_token.to_s }
    body = JSON.parse(response.body)
    assert body['included'][0]['attributes']['stat']['data']['calendar'] == []
  end
end
