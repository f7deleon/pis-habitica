# frozen_string_literal: true

require 'test_helper'

class FindGroupTest < ActionDispatch::IntegrationTest
  def setup
    # Create users
    @user = User.create(nickname: 'Pai', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        "password": @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    @user1 = User.create(nickname: 'German', email: 'example1@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user1.email,
        "password": @user1.password
      }
    }
    @user1_token = JSON.parse(response.body)['jwt']

    @user2 = User.create(nickname: 'Feli', email: 'example2@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user2.email,
        "password": @user2.password
      }
    }
    @user2_token = JSON.parse(response.body)['jwt']

    @user3 = User.create(nickname: 'Example3', email: 'example3@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user3.email,
        "password": @user3.password
      }
    }
    @user3_token = JSON.parse(response.body)['jwt']

    @user4 = User.create(nickname: 'Example4', email: 'example4@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user4.email,
        "password": @user4.password
      }
    }
    @user4_token = JSON.parse(response.body)['jwt']

    @user5 = User.create(nickname: 'Example5', email: 'example5@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user5.email,
        "password": @user5.password
      }
    }
    @user5_token = JSON.parse(response.body)['jwt']

    # Characters
    @character = Character.create(name: 'Humano', description: 'Descripcion humano')
    @character1 = Character.create(name: 'Brujo', description: 'Descripcion brujo')
    @user.add_character(@character.id, '2018-09-07T12:00:00Z')
    @user1.add_character(@character1.id, '2018-09-07T12:00:00Z')
    @user2.add_character(@character1.id, '2018-09-07T12:00:00Z')
    @user3.add_character(@character1.id, '2018-09-07T12:00:00Z')
    @user4.add_character(@character.id, '2018-09-07T12:00:00Z')
    @user5.add_character(@character.id, '2018-09-07T12:00:00Z')

    # Friendships
    Friendship.create(user_id: @user1.id, friend_id: @user.id)
    Friendship.create(user_id: @user1.id, friend_id: @user2.id)
    Friendship.create(user_id: @user1.id, friend_id: @user3.id)
    Friendship.create(user_id: @user4.id, friend_id: @user5.id)

    # Create groups:

    # public groups
    @group = Group.create(name: 'zGrupito prueba', description: 'Grupito prueba desc', privacy: false)
    @group2 = Group.create(name: 'bGrupito prueba2', description: 'Grupito prueba desc', privacy: false)
    @group3 = Group.create(name: 'xGrupito pruelba3', description: 'Grupito prueba desc', privacy: false)
    @group4 = Group.create(name: 'eGrupito pruelba4', description: 'Grupito prueba desc', privacy: false)

    # private groups
    @group1 = Group.create(name: 'Grupito pruebada1', description: 'Grupito prueba desc', privacy: true)

    # Add admins
    Membership.create(user_id: @user1.id, admin: true, group_id: @group.id)
    Membership.create(user_id: @user1.id, admin: true, group_id: @group2.id)
    Membership.create(user_id: @user4.id, admin: true, group_id: @group1.id)

    # Add members (not admins)
    Membership.create(user_id: @user2.id, admin: false, group_id: @group.id)
    Membership.create(user_id: @user5.id, admin: false, group_id: @group1.id)
  end

  test 'Find groups: Filter empty --> return public groups (user is not member of any group)' do
    r = get '/groups?filter=', headers: { 'Authorization': 'Bearer ' + @user3_token.to_s }
    assert r.eql? 200
    body = JSON.parse(response.body)
    assert body['data'].length.eql? 4
    assert body['data'][0]['id'].eql? @group2.id.to_s
    assert body['data'][1]['id'].eql? @group4.id.to_s
    assert body['data'][2]['id'].eql? @group3.id.to_s
    assert body['data'][3]['id'].eql? @group.id.to_s
  end

  test "Find groups: Filter empty --> return public groups and user's groups" do
    r = get '/groups?filter=', headers: { 'Authorization': 'Bearer ' + @user1_token.to_s }
    assert r.eql? 200
    body = JSON.parse(response.body)
    assert body['data'].length.eql? 4
    assert body['data'][0]['id'].eql? @group2.id.to_s
    assert body['data'][1]['id'].eql? @group.id.to_s
    assert body['data'][2]['id'].eql? @group4.id.to_s
    assert body['data'][3]['id'].eql? @group3.id.to_s
  end

  test 'Find groups: Filter = El. Verify that returns 2 groups (both public)' do
    r = get '/groups?filter=El', headers: { 'Authorization': 'Bearer ' + @user3_token.to_s }
    assert r.eql? 200
    body = JSON.parse(response.body)
    assert body['data'].length.eql? 2
    assert body['data'][0]['id'].eql? @group4.id.to_s
    assert body['data'][1]['id'].eql? @group3.id.to_s
  end

  test 'Find groups: Filter= El. Privatize group and verify that returns 1 group(user not member of private group)' do
    @group3.privacy = true
    @group3.save
    @group4.privacy = true
    @group4.save
    r = get '/groups?filter=El', headers: { 'Authorization': 'Bearer ' + @user3_token.to_s }
    assert r.eql? 200
    body = JSON.parse(response.body)
    assert body['data'].length.zero?
  end

  test 'Find groups: Filter= ada. returns empty list (only private group contains that expression in name)' do
    r = get '/groups?filter=ada', headers: { 'Authorization': 'Bearer ' + @user3_token.to_s }
    assert r.eql? 200
    body = JSON.parse(response.body)
    assert body['data'].length.zero?
  end

  test 'Find groups: Filter= ada. returns 1 group (user is member of both private groups)' do
    r = get '/groups?filter=ada', headers: { 'Authorization': 'Bearer ' + @user4_token.to_s }
    assert r.eql? 200
    body = JSON.parse(response.body)
    assert body['data'].length.eql? 1
    assert body['data'][0]['id'].eql? @group1.id.to_s
  end

  test 'Find groups: GET without authentication token' do
    r = get '/groups?filter=' + @group.id.to_s, headers: { 'Authorization': 'Bearer FAKETOKEN' }
    assert r.eql? 401
  end
end
