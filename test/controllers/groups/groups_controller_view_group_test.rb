# frozen_string_literal: true

require 'test_helper'
# Endpoint /users/user_id/groups/id
class GroupsControllerViewGroupTest < ActionDispatch::IntegrationTest
  def setup
    # Create users
    @user = User.create(nickname: 'Example', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        "password": @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    @user1 = User.create(nickname: 'Example1', email: 'example1@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user1.email,
        "password": @user1.password
      }
    }
    @user1_token = JSON.parse(response.body)['jwt']

    @user2 = User.create(nickname: 'Example2', email: 'example2@example.com', password: 'Example123')
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

    # Characters
    @character = Character.create(name: 'Humano', description: 'Descripcion humano')
    @character1 = Character.create(name: 'Brujo', description: 'Descripcion brujo')
    @user_character = UserCharacter.create(user_id: @user.id,
                                           character_id: @character.id,
                                           creation_date: '2018-09-07T12:00:00Z',
                                           is_alive: true)
    @user_character1 = UserCharacter.create(user_id: @user1.id,
                                            character_id: @character1.id,
                                            creation_date: '2018-09-07T12:00:00Z',
                                            is_alive: true)
    @user_character2 = UserCharacter.create(user_id: @user2.id,
                                            character_id: @character1.id,
                                            creation_date: '2018-09-07T12:00:00Z',
                                            is_alive: true)
    @user_character3 = UserCharacter.create(user_id: @user3.id,
                                            character_id: @character1.id,
                                            creation_date: '2018-09-07T12:00:00Z',
                                            is_alive: true)

    # Create groups:

    # public group
    @group = Group.create(name: 'Grupito prueba', description: 'Grupito prueba desc', privacy: false)

    # private group
    @group1 = Group.create(name: 'Grupito prueba1', description: 'Grupito prueba desc', privacy: true)
    @group2 = Group.create(name: 'Grupito prueba2', description: 'Grupito prueba desc', privacy: true)

    # Add admins
    Membership.create(user_id: @user.id, admin: true, group_id: @group.id)
    Membership.create(user_id: @user.id, admin: true, group_id: @group1.id)
    # membership1 = Membership.create(user_id: @user.id, admin: true, group_id: @group2.id)

    # Add members (not admins)
    Membership.create(user_id: @user1.id, admin: false, group_id: @group.id)
    Membership.create(user_id: @user2.id, admin: false, group_id: @group.id)
    Membership.create(user_id: @user3.id, admin: false, group_id: @group1.id)

    # Add group_habits to groups
    GroupHabit.create(name: 'Correr', description: 'Corer mucho', difficulty: 2,
                      privacy: 1, frequency: 1, active: true,
                      group_id: @group.id, negative: false)
    GroupHabit.create(name: 'Cantar', description: 'Lala', difficulty: 1,
                      privacy: 1, frequency: 2, active: true,
                      group_id: @group.id, negative: false)
    GroupHabit.create(name: 'Comer sano', description: 'Comer',
                      difficulty: 1, privacy: 1, frequency: 2, active: true,
                      group_id: @group1.id, negative: false)
  end

  test 'View @user1s public @group being @user3' do
    url = '/users/' + @user1.id.to_s + '/groups/' + @group.id.to_s
    result = get url, headers: { 'Authorization': 'Bearer ' + @user3_token }
    assert result == 200
    body = JSON.parse(response.body)

    assert body['data']['id'] == @group.id.to_s
    assert body['data']['type'] == 'group'
    assert body['data']['attributes']['name'] == @group.name
    assert body['data']['attributes']['description'] == @group.description
    assert body['data']['attributes']['privacy'] == @group.privacy
    assert body['data']['relationships']['members']['data'].length == 2
    assert body['data']['relationships']['admin']['data']['id'] == @user.id.to_s
    assert body['data']['relationships']['group_habits']['data'].length == 2

    # included data - 2 members and 1 admin, 2 group_habits
    assert body['included'].length == 5
    assert body['included'][0]['type'] == 'user'
    assert body['included'][0]['attributes']['nickname'] == @user.nickname
    assert body['included'][1]['type'] == 'group_habit'
    assert body['included'][2]['type'] == 'group_habit'
    assert body['included'][3]['type'] == 'user'
    assert body['included'][4]['type'] == 'user'
  end

  test 'View @user3s private @group1 being @user1' do
    url = '/users/' + @user3.id.to_s + '/groups/' + @group1.id.to_s
    result = get url, headers: { 'Authorization': 'Bearer ' + @user1_token }
    assert result == 403
    body = JSON.parse(response.body)
    assert body['errors'][0]['message'] == 'Current user does not belong to this group'
    assert body['errors'][0]['title'] == 'Unauthorized'
  end

  test 'View group that does not exist' do
    url = '/users/' + @user3.id.to_s + '/groups/' + '4'
    result = get url, headers: { 'Authorization': 'Bearer ' + @user1_token }
    assert result == 404
    body = JSON.parse(response.body)
    assert body['errors'][0]['message'] == 'There is no group with the given id'
    assert body['errors'][0]['title'] == 'Not found'
  end

  test 'View @users3 private @group1, but now @user1 is a member' do
    Membership.create(user_id: @user1.id, admin: false, group_id: @group1.id)
    url = '/users/' + @user3.id.to_s + '/groups/' + @group1.id.to_s
    result = get url, headers: { 'Authorization': 'Bearer ' + @user1_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert body['data']['id'] == @group1.id.to_s
    assert body['data']['type'] == 'group'
    assert body['data']['attributes']['name'] == @group1.name
    assert body['data']['attributes']['description'] == @group1.description
    assert body['data']['attributes']['privacy'] == @group1.privacy
    assert body['data']['relationships']['members']['data'].length == 2
    assert body['data']['relationships']['admin']['data']['id'] == @user.id.to_s
    assert body['data']['relationships']['group_habits']['data'].length == 1

    # included data - 2 members and 1 admin, 1 group_habit
    assert body['included'].length == 4
    assert body['included'][0]['type'] == 'user'
    assert body['included'][0]['attributes']['nickname'] == @user.nickname
    assert body['included'][1]['type'] == 'group_habit'
    assert body['included'][2]['type'] == 'user'
    assert body['included'][2]['attributes']['nickname'] == @user1.nickname
    assert body['included'][3]['type'] == 'user'
  end
end
