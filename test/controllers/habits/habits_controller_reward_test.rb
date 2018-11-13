# frozen_string_literal: true

require 'test_helper'

class HabitsControllerRewardTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'Example', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        'password': @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    @individual_habit_to_track = IndividualHabit.create(
      user_id: @user.id,
      name: 'Example',
      description: 'Example',
      difficulty: 3,
      privacy: 1,
      frequency: 1,
      active: true
    )

    @individual_habit_to_track1 = IndividualHabit.create(
      user_id: @user.id,
      name: 'Example1',
      description: 'Example1',
      difficulty: 2,
      privacy: 1,
      frequency: 1,
      active: true
    )

    @individual_habit_to_track2 = IndividualHabit.create(
      user_id: @user.id,
      name: 'Example1',
      description: 'Example1',
      difficulty: 1,
      privacy: 1,
      frequency: 1,
      active: true
    )
    # Characters
    @char = Character.create(name: 'Mago', description: I18n.t('mage_description'))
    req = {
      'data': {
        'id': @char.id.to_s,
        'type': 'characters',
        'attributes': { 'name': 'Mago', 'description': I18n.t('mage_description') }
      },
      'included': [{ 'type': 'date', 'attributes': { 'date': '2018-09-07T12:00:00Z' } }]
    }
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: req
  end

  test 'should be valid' do
    assert @user.valid?
    assert @individual_habit_to_track.valid?
    assert @individual_habit_to_track1.valid?
    assert @individual_habit_to_track2.valid?
  end
  test 'fullfill one more habit and check health and experience increase.' do
    @user.health = 30
    @user.save
    post '/habits/' + @individual_habit_to_track1.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:29+00:00' } }
    }
    body = JSON.parse(response.body)
    h_diff = @individual_habit_to_track1.increment_of_health(@user)
    assert body['data']['attributes']['health_difference'].eql? h_diff
    exp_diff = @individual_habit_to_track1.increment_of_experience(@user)
    assert body['data']['attributes']['experience_difference'].eql? exp_diff
    assert body['data']['relationships']['individual_habit']['data']['id'].eql? @individual_habit_to_track1.id.to_s
  end
  test 'fullfill another habit of the user.' do
    @user.health = 30
    @user.save
    post '/habits/' + @individual_habit_to_track2.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:37+00:00' } }
    }
    body = JSON.parse(response.body)
    h_diff = @individual_habit_to_track2.increment_of_health(@user)
    assert body['data']['attributes']['health_difference'].eql? h_diff
    assert body['data']['relationships']['individual_habit']['data']['id'].eql? @individual_habit_to_track2.id.to_s
  end
  test 'RecompensarHabito: Check level up' do
    past_level = @user.level
    level = past_level
    while past_level == level
      post '/habits/' + @individual_habit_to_track.id.to_s + '/fulfill', headers: {
        'Authorization': 'Bearer ' + @user_token
      }, params: {
        'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:49:29+00:00' } }
      }
      level = User.find_by_id(@user.id).level
      body = JSON.parse(response.body) if level > past_level
    end
    assert body['data']['attributes']['health'].eql? User.find_by_id(@user.id).max_health
    assert body['data']['attributes']['experience'].eql? 12
    assert body['data']['attributes']['max_experience'].eql? User.find_by_id(@user.id).max_experience
    assert body['data']['attributes']['level_up']
    assert body['data']['attributes']['level'].eql? past_level + 1
    assert body['data']['relationships']['individual_habit']['data']['id'].eql? @individual_habit_to_track.id.to_s
  end
  test 'No health increment if fulfill habit and previous health was max_health' do
    # first set health to max health.
    previous_level = User.find_by_id(@user.id).level
    @user.health = 96
    @user.save
    # the following request will increase health by 16. Verify that health was set to max_health for level 1
    post '/habits/' + @individual_habit_to_track.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:49:29+00:00' } }
    }
    assert User.find_by_id(@user.id).health.eql? User.find_by_id(@user.id).max_health
    # Then fulfill habit and verify that health still max_health
    post '/habits/' + @individual_habit_to_track.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:49:29+00:00' } }
    }
    assert User.find_by_id(@user.id).health.eql? User.find_by_id(@user.id).max_health
    # Verify that level still the same
    assert User.find_by_id(@user.id).level.eql? previous_level
  end
  test 'If health increment + current Health > max_health, set health to max_health and return correct health diff' do
    @user.health = 96
    @user.save
    # the following request will increase health by 16. Verify that health was set to max_health for level 1
    post '/habits/' + @individual_habit_to_track.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:49:29+00:00' } }
    }
    assert User.find_by_id(@user.id).health.eql? User.find_by_id(@user.id).max_health
  end
  test 'verify that when levelup and experience_diff > required_experience_to_levelup,
        experience =  experience_diff - required_experience_to_levelup' do
    past_level = @user.level
    @user.experience = 96
    @user.save
    post '/habits/' + @individual_habit_to_track.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:49:29+00:00' } }
    }
    level = User.find_by_id(@user.id).level
    body = JSON.parse(response.body) if level > past_level
    assert body['data']['attributes']['health'].eql? User.find_by_id(@user.id).max_health
    # check that remanent experience got set in user.experience 96 + 16 - 100.
    assert body['data']['attributes']['experience'].eql? 12
    assert body['data']['attributes']['max_experience'].eql? User.find_by_id(@user.id).max_experience
    assert body['data']['attributes']['level_up']
    assert body['data']['attributes']['level'].eql? past_level + 1
    assert body['data']['relationships']['individual_habit']['data']['id'].eql? @individual_habit_to_track.id.to_s
  end
end
