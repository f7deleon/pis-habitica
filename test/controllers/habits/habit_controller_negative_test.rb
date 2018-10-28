# frozen_string_literal: true

require 'test_helper'

class HabitsControllerNegativeTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'Example', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        'password': @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    @default_type = DefaultType.create(
      user_id: @user.id,
      name: 'Example',
      description: 'Example'
    )

    # test set_negative
    @individual_habit = IndividualHabit.create(
      user_id: @user.id,
      name: 'ExampleNegative',
      description: 'ExampleNegative',
      difficulty: 3,
      privacy: 1,
      frequency: 1,
      active: true,
      negative: true
    )
  end

  test 'NegativeHabits' do
    post '/me/habits', headers: { 'Authorization': 'Bearer ' + @user_token }, params: {
      'data': {
        'type': 'habit',
        'attributes':
        { 'name': 'Example',
          'description': 'Example',
          'frequency': 1,
          'difficulty': 1,
          'privacy': 1,
          'negative': true },
        'relationships': {
          'types': [
            { 'data': { 'id': @default_type.id, 'type': 'type' } }
          ]
        }
      }
    }
    @expected = { "data": { "id": JSON.parse(response.body)['data']['id'],
                            "type": 'habit', "attributes":
    { "name": 'Example', "description": 'Example', "difficulty": 1, "privacy": 1, "frequency": 1,
      "negative": true, "count_track": 0 },
                            "relationships": { "types":
                            { 'data': [{ 'id': @default_type.id.to_s, 'type': 'type' }] } } } }

    assert @expected.to_json == response.body
  end
  test 'TestNegative' do
    expected = { "data": { "id": @individual_habit.id.to_s,
                           "type": 'habit',
                           "attributes": { "name": 'ExampleNegative', "description": 'ExampleNegative',
                                           "difficulty": 3, "privacy": 1, "frequency": 1,
                                           "negative": true, "count_track": 0 },
                           "relationships": { "types": { "data": [] } } } }
    assert IndividualHabitSerializer.new(@individual_habit).serialized_json == expected.to_json
  end
  test 'checkErrorNegative' do
    post '/me/habits', headers: { 'Authorization': 'Bearer ' + @user_token }, params: {
      'data': {
        'type': 'habit',
        'attributes':
        { 'name': 'Example',
          'description': 'Example',
          'frequency': 2,
          'difficulty': 1,
          'privacy': 1,
          'negative': true },
        'relationships': {
          'types': [
            { 'data': { 'id': @default_type.id, 'type': 'type' } }
          ]
        }
      }
    }
    error_expected = { "errors": [{ "status": 400, "code": 605,
                                    "title": 'frequency invalid',
                                    "details": "You can't create negative habit with daily frequency" }] }
    assert response.body == error_expected.to_json
  end
  test 'existNegativeInDb' do
    post '/me/habits', headers: { 'Authorization': 'Bearer ' + @user_token }, params: {
      'data': {
        'type': 'habit',
        'attributes':
        { 'name': 'Example',
          'description': 'Example',
          'frequency': 1,
          'difficulty': 1,
          'privacy': 1,
          'negative': true },
        'relationships': {
          'types': [
            { 'data': { 'id': @default_type.id, 'type': 'type' } }
          ]
        }
      }
    }
    # habito creado con negative = true
    assert IndividualHabit.find(JSON.parse(response.body)['data']['id'].to_i).negative
  end
end
