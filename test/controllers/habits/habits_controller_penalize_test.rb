# frozen_string_literal: true

require 'test_helper'

class HabitsControllerPenalizeTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'Example', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        'password': @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']
    @habit1 = IndividualHabit.create(
      user_id: @user.id,
      name: 'Example',
      description: 'Example',
      difficulty: 1,
      privacy: 1,
      frequency: 1,
      active: true,
      negative: true
    )
    @habit2 = IndividualHabit.create(
      user_id: @user.id,
      name: 'Example1',
      description: 'Example1',
      difficulty: 2,
      privacy: 1,
      frequency: 1,
      active: true,
      negative: true
    )
    @habit3 = IndividualHabit.create(
      user_id: @user.id,
      name: 'Example1',
      description: 'Example1',
      difficulty: 3,
      privacy: 1,
      frequency: 1,
      active: true,
      negative: true
    )
    @char = Character.create(name: 'Mago', description: I18n.t('mage_description'))
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': {
        'id': @char.id.to_s,
        'type': 'characters',
        'attributes': { 'name': 'Mago', 'description': I18n.t('mage_description') }
      },
      'included': [{ 'type': 'date', 'attributes': { 'date': '2018-09-07T12:00:00Z' } }]
    }
  end

  test 'should be valid' do
    assert @user.valid?
    assert @habit3.valid?
    assert @habit2.valid?
    assert @habit1.valid?
  end

  test 'PenalizarHabito: Health diminish after fulfilling negative habit: Easy' do
    post '/habits/' + @habit1.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:29+00:00', 'negative': true } }
    }
    expected = {
      'data': {
        'id': JSON.parse(response.body)['data']['id'],
        'type': 'track',
        'attributes': {
          'max_health': User.find_by_id(@user.id).max_health,
          'health_difference': @habit1.decrement_of_health(@user),
          'max_experience': User.find_by_id(@user.id).max_experience
        },
        'relationships': { 'individual_habit': { 'data': { 'id': @habit1.id.to_s, 'type': 'individual_habit' } } }
      }
    }
    assert response.body == expected.to_json
    assert_equal((User.find(@user.id).health - @user.max_health), @habit1.decrement_of_health(@user))
  end

  test 'PenalizarHabito: Health diminish after fulfilling negative habit: Medium' do
    post '/habits/' + @habit2.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:29+00:00', 'negative': true } }
    }
    expected = {
      'data': {
        'id': JSON.parse(response.body)['data']['id'],
        'type': 'track',
        'attributes': {
          'max_health': User.find_by_id(@user.id).max_health,
          'health_difference': @habit2.decrement_of_health(@user),
          'max_experience': User.find_by_id(@user.id).max_experience
        },
        'relationships': { 'individual_habit': { 'data': { 'id': @habit2.id.to_s, 'type': 'individual_habit' } } }
      }
    }
    assert response.body == expected.to_json
    assert_equal((User.find(@user.id).health - @user.max_health), @habit2.decrement_of_health(@user))
  end

  test 'PenalizarHabito: Health diminish after fulfilling negative habit: Hard' do
    post '/habits/' + @habit3.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:29+00:00', 'negative': true } }
    }
    expected = {
      'data': {
        'id': JSON.parse(response.body)['data']['id'],
        'type': 'track',
        'attributes': {
          'max_health': User.find_by_id(@user.id).max_health,
          'health_difference': @habit3.decrement_of_health(@user),
          'max_experience': User.find_by_id(@user.id).max_experience
        },
        'relationships': { 'individual_habit': { 'data': { 'id': @habit3.id.to_s, 'type': 'individual_habit' } } }
      }
    }
    assert response.body == expected.to_json
    assert_equal((User.find(@user.id).health - @user.max_health), @habit3.decrement_of_health(@user))
  end

  test 'PenalizarHabito: Character dies when health diminishes to zero. After death is not able to fulfill habits' do
    @user.health = 3
    @user.save

    post '/habits/' + @habit3.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:29+00:00', 'negative': true } } }

    expected = {
      'data': {
        'id': JSON.parse(response.body)['data']['id'],
        'type': 'track',
        'attributes': {
          'max_health': User.find_by_id(@user.id).max_health,
          'health_difference': -3,
          'max_experience': User.find_by_id(@user.id).max_experience,
          'is_dead': true
        }, 'relationships': { 'individual_habit': { 'data': { 'id': @habit3.id.to_s, 'type': 'individual_habit' } } }
      }
    }
    assert expected.to_json == response.body
    assert_equal(User.find(@user.id).experience, 0)
    assert User.find(@user.id).dead?

    post '/habits/' + @habit3.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:29+00:00', 'negative': true } } }
    assert_equal 404, status # Not Found
  end
end
