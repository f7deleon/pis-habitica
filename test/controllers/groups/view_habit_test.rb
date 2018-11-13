# frozen_string_literal: true

require 'test_helper'

class ViewHabitGroupControllerTest < ActionDispatch::IntegrationTest
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

    @group = Group.create(name: 'Grupo', description: 'Propio grupo', privacy: false)

    @group2 = Group.create(name: 'Grupo2', description: 'Propio grupo2', privacy: true)

    Membership.create(user_id: @user.id, group_id: @group.id, admin: true)
    Membership.create(user_id: @user.id, group_id: @group2.id, admin: true)

    @habit = GroupHabit.create(
      group_id: @group.id,
      name: 'Habito',
      description: 'Habito de grupo',
      difficulty: 1,
      frequency: 1,
      negative: false,
      privacy: 1
    )

    @habit2 = GroupHabit.create(
      group_id: @group2.id,
      name: 'Habito2',
      description: 'Habito de grupo2',
      difficulty: 1,
      frequency: 1,
      negative: false,
      privacy: 1
    )

    @expected = {
      "data": {
        "id": @habit.id.to_s,
        "type": 'group_habit',
        "attributes": {
          "name": 'Habito',
          "description": 'Habito de grupo',
          "difficulty": 1,
          "privacy": 1,
          "frequency": 1,
          "negative": false,
          "count_track": 0
        },
        "relationships": {
          "types": {
            "data": []
          }
        }
      },
      "included": []
    }
    @expected2 = {
      "data": {
        "id": @habit2.id.to_s,
        "type": 'group_habit',
        "attributes": {
          "name": 'Habito2',
          "description": 'Habito de grupo2',
          "difficulty": 1,
          "privacy": 1,
          "frequency": 1,
          "negative": false,
          "count_track": 0
        },
        "relationships": {
          "types": {
            "data": []
          }
        }
      },
      "included": []
    }
  end

  test 'ViewHabit: can view' do
    get '/habits/' + @habit.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    assert_equal 200, status
    assert @expected.to_json == response.body
  end

  test 'ViewHabit: can view, no member and privacy false' do
    get '/habits/' + @habit.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user2_token
    }
    assert_equal 200, status
    assert @expected.to_json == response.body
  end

  test 'ViewHabit: cant view habits in group2, privacy true' do
    get '/habits/' + @habit2.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user2_token
    }
    assert_equal 403, status
  end

  test 'ViewHabit: can view habits in group2, member and privacy true' do
    get '/habits/' + @habit2.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    assert_equal 200, status
    assert @expected2.to_json == response.body
  end
end
