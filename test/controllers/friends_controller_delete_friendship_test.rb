# frozen_string_literal: true

require 'test_helper'

class FriendsControllerDeleteFriendshipTest < ActionDispatch::IntegrationTest
  def setup
    @user1 = User.create(nickname: 'user1', email: 'user1@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user1.email,
        "password": @user1.password
      }
    }
    @user1_token = JSON.parse(response.body)['jwt']
    @user2 = User.create(nickname: 'user2', email: 'user2@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user2.email,
        "password": @user2.password
      }
    }
    @user2_token = JSON.parse(response.body)['jwt']
    @friendless_user = User.create(nickname: 'friendless', email: 'friendless@example.com', password: 'Example123')
    @friendship = Friendship.create(user_id: @user1.id, friend_id: @user2.id)
  end

  test 'should be valid' do
    assert @user1.valid?
    assert @user2.valid?
    assert @friendless_user.valid?
    assert @friendship.valid?
  end

  test 'AbandonarAmistad: should destroy friendship' do
    delete '/me/friends/' + @user2.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user1_token
    }
    assert_equal 204, status # No Content

    # Deleted both ways
    assert_not Friendship.find_by(user_id: @user1, friend_id: @user2)
    assert_not Friendship.find_by(user_id: @user2, friend_id: @user1)
    assert_not @user1.friendships.find_by(friend_id: @user2)
    assert_not @user2.friendships.find_by(friend_id: @user1)
    assert_not @user1.friends.find_by(id: @user2.id)
    assert_not @user2.friends.find_by(id: @user1.id)

    delete '/me/friends/' + @user1.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user2_token
    }
    assert_equal 404, status # Not Found
  end
  test 'AbandonarAmistad: user should exist' do
    delete '/me/friends/' + @user2.id.to_s, headers: {
      'Authorization': 'Bearer asdasdasd'
    }
    assert_equal 401, status # Unauthorized
  end
  test 'AbandonarAmistad: friend should exist' do
    delete '/me/friends/123213123123', headers: {
      'Authorization': 'Bearer ' + @user1_token
    }
    assert_equal 404, status # Not Found
  end
  test 'AbandonarAmistad: friend should be your friend' do
    delete '/me/friends/' + @friendless_user.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user1_token
    }
    assert_equal 404, status # Not Found
  end
end
