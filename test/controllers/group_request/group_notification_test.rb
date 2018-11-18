# frozen_string_literal: true

require 'test_helper'

class GroupNotificationTest < ActionDispatch::IntegrationTest
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
    @user2.user_characters << @user_character

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

    @group_request_notification = GroupRequestNotification.new(user_id: @user2.id, group_request_id: @request.id)

    @group_request_notification.save!

    options = {}
    options[:include] = %i[sender group_request group]
    options[:params] = { current_user: @user2 }
    @request_serializer = NotificationSerializer.new([@group_request_notification], options).serialized_json
  end

  test 'List Group Request Notification' do
    url = '/me/notifications'
    result = get url, headers: { 'Authorization': 'Bearer ' + @user2_token }
    assert result == 200
    body = JSON.parse(response.body)
    body['data'][0]['relationships']['sender']['data']['id'].eql? @user3.id.to_s
    body['included'][0]['id'].eql? @group2.id.to_s
    body['included'][1]['id'].eql? @user2.id.to_s
  end

  test 'Send antoher group request to group2' do
    url = '/groups/' + @group2.id.to_s + '/requests'
    result = post url, headers: { 'Authorization': 'Bearer ' + @user3_token }
    assert result == 409
  end

  test 'List group request' do
    url = '/groups/' + @group2.id.to_s + '/requests'
    result = get url, headers: { 'Authorization': 'Bearer ' + @user2_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert @request_serializer == body.to_json
  end

  test 'Send request with unknown token' do
    url = '/groups/' + @group2.id.to_s + '/requests'
    result = post url, headers: { 'Authorization': 'Bearer unknown ' }
    assert result == 401
  end

  test 'Send request to unknown group' do
    url = '/groups/90909/requests'
    result = post url, headers: { 'Authorization': 'Bearer ' + @user3_token }
    assert result == 404
  end

  test 'Send request to a group that is member' do
    url = '/groups/' + @group.id.to_s + '/requests'
    result = post url, headers: { 'Authorization': 'Bearer ' + @user3_token }
    assert result == 409
  end
end
