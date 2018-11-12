# frozen_string_literal: true

require 'test_helper'

class AbandonGroupTest < ActionDispatch::IntegrationTest
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
    @group2 = Group.create(name: 'Grupito prueba2', description: 'Grupito prueba desc', privacy: false)

    # Add admins
    Membership.create(user_id: @user1.id, admin: true, group_id: @group.id)
    Membership.create(user_id: @user4.id, admin: true, group_id: @group1.id)
    Membership.create(user_id: @user4.id, admin: true, group_id: @group2.id)

    # Add members (not admins)
    Membership.create(user_id: @user2.id, admin: false, group_id: @group.id)
    Membership.create(user_id: @user5.id, admin: false, group_id: @group1.id)

    # create a group habit
    @habit = GroupHabit.create(
      group_id: @group2.id,
      name: 'Example',
      description: 'Example',
      difficulty: 3,
      privacy: 1,
      frequency: 2,
      active: true,
      negative: false
    )
    @group2_id = @group2.id
    @habit_id = @habit.id
  end

  test 'Abandon group: not admin user abandon group' do
    r = delete '/me/groups/' + @group.id.to_s, headers: { 'Authorization': 'Bearer ' + @user2_token.to_s }
    assert r, 204
    assert Group.all.find_by_id(@group.id).memberships.length.eql? 1
    assert Group.all.find_by_id(@group.id).memberships.first.user_id, @user1.id
  end

  test 'Abandon group: admin user abandon group. Verify oldest member is the new admin' do
    r = delete '/me/groups/' + @group1.id.to_s, headers: { 'Authorization': 'Bearer ' + @user4_token.to_s }
    assert r, 204
    assert Group.all.find_by_id(@group1.id).memberships.first.user_id, @user5.id
    assert Group.all.find_by_id(@group1.id).memberships.first.admin, true
  end

  test 'Abandon group: user that do not belong to the group, try abandon the group' do
    r = delete '/me/groups/' + @group.id.to_s, headers: { 'Authorization': 'Bearer ' + @user3_token.to_s }
    assert r, 404
  end

  test 'Abandon group: user abandon a group that does not exist' do
    r = delete '/me/groups/999999999', headers: { 'Authorization': 'Bearer ' + @user3_token.to_s }
    assert r, 404
  end

  test 'Abandon group: delete without authentication token' do
    r = delete '/me/groups/' + @group1.id.to_s, headers: { 'Authorization': 'Bearer FAKEFAKE' }
    assert r, 404
  end

  test 'Abandon group: error in URL' do
    r = delete '/me/groups/r', headers: { 'Authorization': 'Bearer ' + @user5_token.to_s }
    assert r, 404
  end

  test 'Abandon group: admin and only member abandon group. Group gets deleted' do
    r = delete '/me/groups/' + @group2.id.to_s, headers: { 'Authorization': 'Bearer ' + @user4_token.to_s }
    assert r, 204
    assert Group.all.find_by_id(@group2.id).nil?
    assert GroupHabit.all.find_by_id(@habit.id).nil?
  end
end
