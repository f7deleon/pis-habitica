# frozen_string_literal: true

require 'test_helper'

class NotAcceptMemberTest < ActionDispatch::IntegrationTest
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

    @character = Character.create(name: 'Humano', description: 'Descripcion humano')
    @user_character = UserCharacter.create(user_id: @user2.id,
                                           character_id: @character.id,
                                           creation_date: '2018-09-07T12:00:00Z',
                                           is_alive: true)

    @user3 = User.create(nickname: 'Example3', email: 'example3@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user3.email,
        'password': @user3.password
      }
    }
    @user3_token = JSON.parse(response.body)['jwt']

    @group = Group.create(name: 'Grupo', description: 'Propio grupo', privacy: false)

    @group2 = Group.create(name: 'Grupo2', description: 'Propio grupo2', privacy: false)

    @group3 = Group.create(name: 'Grupo3', description: 'Propio grupo3', privacy: false)

    Membership.create(user_id: @user.id, group_id: @group.id, admin: true)
    Membership.create(user_id: @user2.id, group_id: @group2.id, admin: true)
    Membership.create(user_id: @user3.id, group_id: @group.id, admin: false)

    @request = GroupRequest.new(
      user_id: @user3.id,
      receiver_id: @user2.id,
      group_id: @group2.id
    )

    @request.save!

    @request_serializer = GroupRequestSerializer.new([@request]).serialized_json

    @group_request_notification = GroupRequestNotification.new(user_id: @user2.id, group_request_id: @request.id)

    @group_request_notification.save!
  end

  test 'Reject member' do
    url = '/groups/' + @group2.id.to_s + '/requests/' + @request.id.to_s
    result = delete url, headers: { 'Authorization': 'Bearer ' + @user2_token }
    assert result == 204
  end

  test 'User2 notifications' do
    url = '/me/notifications'
    result = get url, headers: { 'Authorization': 'Bearer ' + @user2_token }
    assert result == 200
    body = JSON.parse(response.body)
    body['data'].eql? []
  end

  test 'Not Authorized' do
    url = '/groups/' + @group2.id.to_s + '/requests/' + @request.id.to_s
    result = post url, headers: { 'Authorization': 'Bearer cualquiera' }
    assert result == 401
  end

  test 'Request Not Found' do
    url = '/groups/' + @group2.id.to_s + '/requests/1212120'
    result = post url, headers: { 'Authorization': 'Bearer ' + @user2_token }
    assert result == 404
  end

  test 'Group Not Found' do
    url = '/groups/565656565/requests/' + @request.id.to_s
    result = post url, headers: { 'Authorization': 'Bearer ' + @user2_token }
    assert result == 404
  end
end
