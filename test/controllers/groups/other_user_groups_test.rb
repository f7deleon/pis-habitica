# frozen_string_literal: true

require 'test_helper'

class OtherUserGroupsTest < ActionDispatch::IntegrationTest
  def setup
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

    # Characters
    @character = Character.create(name: 'Humano', description: 'Descripcion humano')
    @character1 = Character.create(name: 'Brujo', description: 'Descripcion brujo')
    @user.add_character(@character.id, '2018-09-07T12:00:00Z')
    @user1.add_character(@character1.id, '2018-09-07T12:00:00Z')
    @user2.add_character(@character1.id, '2018-09-07T12:00:00Z')

    # Friendships
    Friendship.create(user_id: @user1.id, friend_id: @user.id)
    Friendship.create(user_id: @user1.id, friend_id: @user2.id)

    # public groups
    @group = Group.create(name: 'zGrupito prueba', description: 'Grupito prueba desc', privacy: false)
    @group2 = Group.create(name: 'bGrupito prueba2', description: 'Grupito prueba desc', privacy: false)

    # private groups
    @group1 = Group.create(name: 'Grupito pruebada1', description: 'Grupito prueba desc', privacy: true)
    # Add admins
    Membership.create(user_id: @user.id, admin: true, group_id: @group.id)
    Membership.create(user_id: @user1.id, admin: true, group_id: @group1.id)
    Membership.create(user_id: @user2.id, admin: true, group_id: @group2.id)
    # Add members (not admins)
    Membership.create(user_id: @user.id, admin: false, group_id: @group2.id)
    Membership.create(user_id: @user.id, admin: false, group_id: @group1.id)
  end

  test 'Other user groups: Get @user groups. verify that private group that
        @user2 does not belong, is not returned' do
    r = get '/users/' + @user.id.to_s + '/groups', headers: { 'Authorization': 'Bearer ' + @user2_token.to_s }
    assert r.eql? 200
    body = JSON.parse(response.body)
    assert body['data'].length.eql? 2
    assert body['data'][0]['id'].eql? @group2.id.to_s
    assert body['data'][1]['id'].eql? @group.id.to_s
  end

  test 'Other user groups: Get @user groups. verify that private group that
        @user1 does belong, is returned' do
    r = get '/users/' + @user.id.to_s + '/groups', headers: { 'Authorization': 'Bearer ' + @user1_token.to_s }
    assert r.eql? 200
    body = JSON.parse(response.body)
    assert body['data'].length.eql? 3
    assert body['data'][0]['id'].eql? @group1.id.to_s
    assert body['data'][1]['id'].eql? @group2.id.to_s
    assert body['data'][2]['id'].eql? @group.id.to_s
  end

  test 'Find groups: GET without authentication token' do
    r = get '/groups?filter=' + @group.id.to_s, headers: { 'Authorization': 'Bearer FAKETOKEN' }
    assert r.eql? 401
  end
end
