# frozen_string_literal: true

require 'test_helper'

class RequestsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'user', email: 'user@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        "password": @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']
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
    @user3 = User.create(nickname: 'user3', email: 'user3@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user3.email,
        "password": @user3.password
      }
    }
    @user3_token = JSON.parse(response.body)['jwt']

    # Create request from user to user 1
    @request0 = Request.new
    @request0.user_id = @user.id
    @request0.receiver_id = @user1.id
    @request0.save

    @user.requests_sent << @request0
    @user1.requests_received << @request0

    # Create request from user1 to user 2
    @request1 = Request.new
    @request1.user_id = @user1.id
    @request1.receiver_id = @user2.id
    @request1.save

    @user1.requests_sent << @request1
    @user2.requests_received << @request1

    # Create request from user3 to user 2
    @request2 = Request.new
    @request2.user_id = @user3.id
    @request2.receiver_id = @user2.id
    @request2.save

    @user3.requests_sent << @request2
    @user2.requests_received << @request2
  end

  test 'List requests of user 1' do
    get '/me/requests/', headers: { 'Authorization': 'Bearer ' + @user1_token }
    assert_equal 200, status
    body = JSON.parse(response.body)
    assert body['data'].length == 1
    assert body['data'][0]['relationships']['sender']['data']['id'].eql? @user.id.to_s
    assert body['data'][0]['relationships']['receiver']['data']['id'].eql? @user1.id.to_s
  end

  test 'List requests of user 2' do
    get '/me/requests/', headers: { 'Authorization': 'Bearer ' + @user2_token }
    assert_equal 200, status
    body = JSON.parse(response.body)
    assert body['data'].length == 2
    assert body['data'][0]['relationships']['sender']['data']['id'].eql? @user1.id.to_s
    assert body['data'][1]['relationships']['sender']['data']['id'].eql? @user3.id.to_s
    assert body['data'][0]['relationships']['receiver']['data']['id'].eql? @user2.id.to_s
    assert body['data'][1]['relationships']['receiver']['data']['id'].eql? @user2.id.to_s
  end

  test 'List requests of user 3' do
    get '/me/requests/', headers: { 'Authorization': 'Bearer ' + @user3_token }
    assert_equal 200, status
    body = JSON.parse(response.body)
    assert body['data'].empty?
  end

  test 'List request with worn token' do
    get '/me/requests/', headers: { 'Authorization': 'Bearer wrongTokEN' }
    assert_equal 401, status
  end
end
