# frozen_string_literal: true

require 'test_helper'

class NotificationControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'NotificationController1',
                        email: 'NotificationController1@NotificationController1.com',
                        password: 'NotificationController1234')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        "password": @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    @user2 = User.create(nickname: 'NotificationController2',
                         email: 'NotificationController2@NotificationController2.com',
                         password: 'NotificationController1234')
    post '/user_token', params: {
      'auth': {
        'email': @user2.email,
        "password": @user2.password
      }
    }
    @user2_token = JSON.parse(response.body)['jwt']

    @user3 = User.create(nickname: 'NotificationController3',
                         email: 'NotificationController3@NotificationController3.com',
                         password: 'NotificationController1234')
    post '/user_token', params: {
      'auth': {
        'email': @user3.email,
        "password": @user3.password
      }
    }
    @user3_token = JSON.parse(response.body)['jwt']

    @user4 = User.create(nickname: 'NotificationController4',
                         email: 'NotificationController4@NotificationController4.com',
                         password: 'NotificationController1234')
    post '/user_token', params: {
      'auth': {
        'email': @user4.email,
        "password": @user4.password
      }
    }
    @user4_token = JSON.parse(response.body)['jwt']

    @user5 = User.create(nickname: 'NotificationController5',
                         email: 'NotificationController5@NotificationController5.com',
                         password: 'NotificationController1234')
    post '/user_token', params: {
      'auth': {
        'email': @user5.email,
        "password": @user5.password
      }
    }
    @user5_token = JSON.parse(response.body)['jwt']

    @user6 = User.create(nickname: 'NotificationController6',
                         email: 'NotificationController6@NotificationController6.com',
                         password: 'NotificationController1234')
    post '/user_token', params: {
      'auth': {
        'email': @user6.email,
        "password": @user6.password
      }
    }
    @user6_token = JSON.parse(response.body)['jwt']

    # user1 send friend request to user2
    @req1 = Request.new
    @req1.user_id = @user.id
    @req1.receiver_id = @user2.id
    @req1.save

    @fr1 = FriendRequestNotification.new
    @fr1.user_id = @user2.id
    @fr1.request_id = @req1.id
    @fr1.seen = false
    @fr1.save

    # user2 accept friendship to user1
    @fn = FriendshipNotification.new
    @fn.sender_id = @user2.id
    @fn.user_id = @user.id
    @fn.seen = false
    @fn.save

    # user3 send friend request to user1
    @req2 = Request.new
    @req2.user_id = @user3.id
    @req2.receiver_id = @user.id
    @req2.save

    @fr2 = FriendRequestNotification.new
    @fr2.user_id = @user.id
    @fr2.request_id = @req2.id
    @fr2.seen = false
    @fr2.save

    # Add 5 Notifications to user 4
    @notification_user4_seen1 = FriendshipNotification.new
    @notification_user4_seen1.sender_id = @user.id
    @notification_user4_seen1.user_id = @user4.id
    @notification_user4_seen1.seen = true
    @notification_user4_seen1.save

    @notification_user4_seen2 = FriendshipNotification.new
    @notification_user4_seen2.sender_id = @user2.id
    @notification_user4_seen2.user_id = @user4.id
    @notification_user4_seen2.seen = true
    @notification_user4_seen2.save

    @notification_user4_seen3 = FriendshipNotification.new
    @notification_user4_seen3.sender_id = @user3.id
    @notification_user4_seen3.user_id = @user4.id
    @notification_user4_seen3.seen = true
    @notification_user4_seen3.save

    @notification_user4_seen4 = FriendshipNotification.new
    @notification_user4_seen4.sender_id = @user5.id
    @notification_user4_seen4.user_id = @user4.id
    @notification_user4_seen4.seen = false
    @notification_user4_seen4.save

    @notification_user4_seen5 = FriendshipNotification.new
    @notification_user4_seen5.sender_id = @user6.id
    @notification_user4_seen5.user_id = @user4.id
    @notification_user4_seen5.seen = false
    @notification_user4_seen5.save
  end

  test 'Get both types of notification of @user' do
    result = get '/me/notifications?type=', headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert_not body['data'][0]['attributes']['type'].eql? body['data'][1]['attributes']['type']
    assert body['data'].length == 2
  end

  test 'Get FriendshipNotification of @user' do
    result = get '/me/notifications?type=FriendshipNotification',
                 headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert body['data'][0]['attributes']['type'].eql? 'FriendshipNotification'
    assert body['data'].length == 1
    assert body['data'][0]['relationships']['sender']['data']['id'].eql? @user2.id.to_s
    assert body['included'][0]['id'].eql? @user2.id.to_s
  end

  test 'Get FriendRequestNotification of @user' do
    result = get '/me/notifications?type=FriendRequestNotification',
                 headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert body['data'][0]['attributes']['type'].eql? 'FriendRequestNotification'
    assert body['data'].length == 1
    assert body['data'][0]['relationships']['request']['data']['id'].eql? @req2.id.to_s
    assert body['included'][0]['relationships']['sender']['data']['id'].eql? @user3.id.to_s
    assert body['included'][0]['relationships']['receiver']['data']['id'].eql? @user.id.to_s
    assert body['included'][1]['id'].eql? @user3.id.to_s
  end

  test 'Get FriendRequestNotification of @user2' do
    result = get '/me/notifications?type=FriendRequestNotification',
                 headers: { 'Authorization': 'Bearer ' + @user2_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert body['data'][0]['attributes']['type'].eql? 'FriendRequestNotification'
    assert body['data'].length == 1
  end

  test 'Get Notifications of @user3 (should be 0)' do
    result = get '/me/notifications?type=',
                 headers: { 'Authorization': 'Bearer ' + @user3_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert body['data'].length.zero?
  end

  test 'Get List of notifications with wrong token of @user1' do
    result = get '/me/notifications?type=FriendRequestNotification',
                 headers: { 'Authorization': 'Bearer estoescualca' }
    assert result == 401
  end

  test 'Verify that notifications are ordered by seen (starting in false) and then marked as seen' do
    result = get '/me/notifications?type=',
                 headers: { 'Authorization': 'Bearer ' + @user4_token }
    # verify that notifications not seen are first
    assert result == 200
    body = JSON.parse(response.body)
    assert body['data'][0]['attributes']['seen'] == false
    assert body['data'][1]['attributes']['seen'] == false
    assert body['data'][2]['attributes']['seen'] == true
    assert body['data'][3]['attributes']['seen'] == true
    assert body['data'][4]['attributes']['seen'] == true
    # verify that notifications not seen are marked as seen
    noti1 = Notification.find_by_id(@notification_user4_seen4.id)
    noti2 = Notification.find_by_id(@notification_user4_seen5.id)
    assert noti1.seen
    assert noti2.seen
  end
end
