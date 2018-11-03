# frozen_string_literal: true

require 'test_helper'

class UpdateGroupMembersTest < ActionDispatch::IntegrationTest
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

  test 'Update members: [user1*,user2] -- > [user1*,user3]' do
    parameters = { "data": [{ "id": @user3.id.to_s, "type": 'user' }] }
    r = post '/me/groups/' + @group.id.to_s + '/members', headers: { 'Authorization': 'Bearer ' + @user1_token.to_s },
                                                          params: parameters
    assert r.eql? 201
    memberships = Membership.select { |m| m[:group_id] == @group.id }
    members_id_expected = [@user1.id, @user3.id]
    assert memberships.length.eql? 2
    assert members_id_expected.include? memberships[0].user_id
    assert members_id_expected.include? memberships[1].user_id
    # case: [user1*,user3] -- > [user0,user1*,user2,user3]
    parameters = { "data": [{ "id": @user.id.to_s, "type": 'user' },
                            { "id": @user2.id.to_s, "type": 'user' },
                            { "id": @user3.id.to_s, "type": 'user' }] }
    r = post '/me/groups/' + @group.id.to_s + '/members', headers: { 'Authorization': 'Bearer ' + @user1_token.to_s },
                                                          params: parameters
    assert r.eql? 201
    memberships = Membership.select { |m| m[:group_id] == @group.id }
    members_id_expected = [@user1.id, @user3.id, @user.id, @user2.id]
    assert memberships.length.eql? 4
    assert members_id_expected.include? memberships[0].user_id
    assert members_id_expected.include? memberships[1].user_id
    assert members_id_expected.include? memberships[2].user_id
    assert members_id_expected.include? memberships[3].user_id
  end

  test 'Update members: add more than once a user. Verify its added only once' do
    parameters = { "data": [{ "id": @user3.id.to_s, "type": 'user' },
                            { "id": @user3.id.to_s, "type": 'user' },
                            { "id": @user3.id.to_s, "type": 'user' }] }
    r = post '/me/groups/' + @group.id.to_s + '/members', headers: { 'Authorization': 'Bearer ' + @user1_token.to_s },
                                                          params: parameters
    assert r.eql? 201
    memberships = Membership.select { |m| m[:group_id] == @group.id }
    members_id_expected = [@user1.id, @user3.id]
    assert memberships.length.eql? 2
    assert members_id_expected.include? memberships[0].user_id
    assert members_id_expected.include? memberships[1].user_id
  end

  test 'Update members: [user1*,user2] -- > [user1*, user2, user3] -- > [user1*,user2]' do
    parameters = { "data": [{ "id": @user2.id.to_s, "type": 'user' },
                            { "id": @user3.id.to_s, "type": 'user' }] }
    r = post '/me/groups/' + @group.id.to_s + '/members', headers: { 'Authorization': 'Bearer ' + @user1_token.to_s },
                                                          params: parameters
    assert r.eql? 201
    memberships = Membership.select { |m| m[:group_id] == @group.id }
    members_id_expected = [@user1.id, @user2.id, @user3.id]
    assert memberships.length.eql? 3
    assert members_id_expected.include? memberships[0].user_id
    assert members_id_expected.include? memberships[1].user_id
    assert members_id_expected.include? memberships[2].user_id
    # case: [user1*, user2, user3] -- > [user1*,user2]
    parameters = { "data": [{ "id": @user2.id.to_s, "type": 'user' }] }
    r = post '/me/groups/' + @group.id.to_s + '/members', headers: { 'Authorization': 'Bearer ' + @user1_token.to_s },
                                                          params: parameters
    assert r.eql? 201
    memberships = Membership.select { |m| m[:group_id] == @group.id }
    members_id_expected = [@user1.id, @user2.id]
    assert memberships.length.eql? 2
    assert members_id_expected.include? memberships[0].user_id
    assert members_id_expected.include? memberships[1].user_id
  end

  test 'Update members: post with empty group' do
    parameters = { "data": [] }
    r = post '/me/groups/' + @group.id.to_s + '/members', headers: { 'Authorization': 'Bearer ' + @user1_token.to_s },
                                                          params: parameters
    assert r.eql? 400
  end

  test 'Update members: post without authentication token' do
    parameters = { "data": [{ "id": @user4.id.to_s, "type": 'user' },
                            { "id": @user2.id.to_s, "type": 'user' }] }
    res = post '/me/groups/' + @group.id.to_s + '/members', headers: { 'Authorization': 'Bearer DTF!!!!!' },
                                                            params: parameters
    assert res.eql? 401
  end

  test 'Update members: post with bad format' do
    parameters = { "da": [{ "id": @user.id.to_s, "type": 'user' },
                          { "id": @user2.id.to_s, "type": 'user' }] }
    r = post '/me/groups/' + @group.id.to_s + '/members', headers: { 'Authorization': 'Bearer ' + @user1_token.to_s },
                                                          params: parameters
    assert r.eql? 400
  end

  test 'Update members: post with a non existent user' do
    parameters = { "data": [{ "id": '44', "type": 'user' },
                            { "id": @user2.id.to_s, "type": 'user' }] }
    r = post '/me/groups/' + @group.id.to_s + '/members', headers: { 'Authorization': 'Bearer ' + @user1_token.to_s },
                                                          params: parameters
    assert r.eql? 404
  end

  test 'Update members: post made by a non admin member of the group' do
    parameters = { "data": [{ "id": @user3.id.to_s, "type": 'user' }] }
    r = post '/me/groups/' + @group.id.to_s + '/members', headers: { 'Authorization': 'Bearer ' + @user2_token.to_s },
                                                          params: parameters
    assert r.eql? 403
  end

  test 'Update members: post made by a non admin and not member of the group' do
    parameters = { "data": [{ "id": @user3.id.to_s, "type": 'user' }] }
    r = post '/me/groups/' + @group.id.to_s + '/members', headers: { 'Authorization': 'Bearer ' + @user5_token.to_s },
                                                          params: parameters
    assert r.eql? 404
  end
  test 'Update members: post made by a non member but is admin in other group' do
    parameters = { "data": [{ "id": @user3.id.to_s, "type": 'user' }] }
    r = post '/me/groups/' + @group.id.to_s + '/members', headers: { 'Authorization': 'Bearer ' + @user4_token.to_s },
                                                          params: parameters
    assert r.eql? 404
  end
end
