# frozen_string_literal: true

require 'test_helper'

class FindUsersControllerTest < ActionDispatch::IntegrationTest
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

    @user1 = User.create(nickname: 'german', email: 'example1@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user1.email,
        "password": @user1.password
      }
    }
    @user1_token = JSON.parse(response.body)['jwt']

    @user2 = User.create(nickname: 'feli', email: 'example2@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user2.email,
        "password": @user2.password
      }
    }
    @user2_token = JSON.parse(response.body)['jwt']

    @user3 = User.create(nickname: 'yExamponyle3', email: 'example3@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user3.email,
        "password": @user3.password
      }
    }
    @user3_token = JSON.parse(response.body)['jwt']

    @user4 = User.create(nickname: 'examponyle4', email: 'example4@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user4.email,
        "password": @user4.password
      }
    }
    @user4_token = JSON.parse(response.body)['jwt']

    @user5 = User.create(nickname: 'aExample5', email: 'example5@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user5.email,
        "password": @user5.password
      }
    }
    @user5_token = JSON.parse(response.body)['jwt']

    @user6 = User.create(nickname: 'cExample6', email: 'example6@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user6.email,
        "password": @user6.password
      }
    }
    @user6_token = JSON.parse(response.body)['jwt']

    # Characters
    @character = Character.create(name: 'Humano', description: 'Descripcion humano')
    @character1 = Character.create(name: 'Brujo', description: 'Descripcion brujo')
    @user.add_character(@character.id, '2018-09-07T12:00:00Z')
    @user1.add_character(@character1.id, '2018-09-07T12:00:00Z')
    @user2.add_character(@character1.id, '2018-09-07T12:00:00Z')
    @user3.add_character(@character1.id, '2018-09-07T12:00:00Z')
    @user4.add_character(@character.id, '2018-09-07T12:00:00Z')
    @user5.add_character(@character.id, '2018-09-07T12:00:00Z')
    @user6.add_character(@character1.id, '2018-09-03T12:00:00Z')

    # Friendships
    Friendship.create(user_id: @user1.id, friend_id: @user.id)
    Friendship.create(user_id: @user1.id, friend_id: @user2.id)
    Friendship.create(user_id: @user1.id, friend_id: @user3.id)
    Friendship.create(user_id: @user4.id, friend_id: @user5.id)

    # Create groups:

    # public group
    @group = Group.create(name: 'Grupito prueba', description: 'Grupito prueba desc', privacy: false)

    # private group
    @group1 = Group.create(name: 'Grupito prueba1', description: 'Grupito prueba desc', privacy: true)

    # Add admins
    Membership.create(user_id: @user1.id, admin: true, group_id: @group.id)
    Membership.create(user_id: @user4.id, admin: true, group_id: @group1.id)

    # Add members (not admins)
    Membership.create(user_id: @user2.id, admin: false, group_id: @group.id)
    Membership.create(user_id: @user5.id, admin: false, group_id: @group1.id)
  end

  test 'Buscar Usuario: empty filter. User with no friends. Returns all users (first page).
        Verify friends and others users groups are ordered alphabetically' do
    result = get '/users?filter=', headers: { 'Authorization': 'Bearer ' + @user1_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert body['data'].length == 6
    assert body['data'][0]['id'].eql? @user2.id.to_s
    assert body['data'][1]['id'].eql? @user.id.to_s
    assert body['data'][2]['id'].eql? @user3.id.to_s
    assert body['data'][3]['id'].eql? @user5.id.to_s
    assert body['data'][4]['id'].eql? @user6.id.to_s
    assert body['data'][5]['id'].eql? @user4.id.to_s
  end

  test 'Buscar Usuario: empty filter. User with friends. Returns friends and rest of users (first page)' do
    result = get '/users?filter=', headers: { 'Authorization': 'Bearer ' + @user6_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert body['data'].length == 6
    assert body['data'][0]['id'].eql? @user5.id.to_s
    assert body['data'][1]['id'].eql? @user4.id.to_s
    assert body['data'][2]['id'].eql? @user2.id.to_s
    assert body['data'][3]['id'].eql? @user1.id.to_s
    assert body['data'][4]['id'].eql? @user.id.to_s
    assert body['data'][5]['id'].eql? @user3.id.to_s
  end

  test 'Buscar Usuario: filter = OnY. Returns 2 users' do
    result = get '/users?filter=OnY', headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert body['data'].length == 2
    assert body['data'][0]['id'].eql? @user4.id.to_s
    assert body['data'][1]['id'].eql? @user3.id.to_s
  end

  test 'Buscar Usuario: fiter = adsasdsa. Returns 0 users' do
    result = get '/users?filter=adsasdsa', headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert body['data'].length.zero?
  end

  test 'Buscar Usuario: dont attach Authorization token (unauthorized returned)' do
    result = get '/users?filter=Ozu'
    assert result == 401
  end
end
