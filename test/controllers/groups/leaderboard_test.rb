# frozen_string_literal: true

require 'test_helper'
# Endpoint /users/user_id/groups/id
class LeaderboardTest < ActionDispatch::IntegrationTest
  def setup
    # Create users
    @admin = User.create(nickname: 'Admin', email: 'pai@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @admin.email,
        'password': @admin.password
      }
    }
    @admin_token = JSON.parse(response.body)['jwt']
    @user1 = User.create(nickname: 'Example1', email: 'example1@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user1.email,
        'password': @user1.password
      }
    }
    @user1_token = JSON.parse(response.body)['jwt']
    @user2 = User.create(nickname: 'Example2', email: 'example2@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user2.email,
        'password': @user2.password
      }
    }
    @user2_token = JSON.parse(response.body)['jwt']
    @user3 = User.create(nickname: 'Example3', email: 'example3@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user3.email,
        'password': @user3.password
      }
    }
    @user3_token = JSON.parse(response.body)['jwt']
    # Characters
    @char = Character.create(name: 'Mago', description: I18n.t('mage_description'))
    req = {
      'data': {
        'id': @char.id.to_s,
        'type': 'characters',
        'attributes': { 'name': 'Mago', 'description': I18n.t('mage_description') }
      },
      'included': [{ 'type': 'date', 'attributes': { 'date': '2018-09-07T12:00:00Z' } }]
    }
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + @user1_token
    }, params: req
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + @user2_token
    }, params: req
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + @user3_token
    }, params: req
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + @admin_token
    }, params: req
    # Create groups:
    @group = Group.create(name: 'Tournament', description: 'Let the games begin', privacy: false)
    # Add admins
    @membership = Membership.create(user_id: @admin.id, admin: true, group_id: @group.id)
    # Add members (not admins)
    @membership1 = Membership.create(user_id: @user1.id, admin: false, group_id: @group.id)
    @membership2 = Membership.create(user_id: @user2.id, admin: false, group_id: @group.id)
    @membership3 = Membership.create(user_id: @user3.id, admin: false, group_id: @group.id)
    # Add group_habits to groups
    @hard = GroupHabit.create(name: 'Correr', description: 'Corer mucho', difficulty: 3,
                              privacy: 1, frequency: 1, active: true,
                              group_id: @group.id, negative: false)
    @easy = GroupHabit.create(name: 'Cantar', description: 'Lala', difficulty: 1,
                              privacy: 1, frequency: 1, active: true,
                              group_id: @group.id, negative: false)
    @negative = GroupHabit.create(name: 'Comer en McDonalds', description: 'Comer',
                                  difficulty: 2, privacy: 1, frequency: 1, active: true,
                                  group_id: @group.id, negative: true)
  end
  test 'should be valid' do
    assert @admin.valid?
    assert @user1.valid?
    assert @user2.valid?
    assert @user3.valid?
    assert @char.valid?
    assert @group.valid?
    assert @membership.valid?
    assert @membership1.valid?
    assert @membership2.valid?
    assert @membership3.valid?
    assert @hard.valid?
    assert @easy.valid?
    assert @negative.valid?
  end
  def fulfill(user_token, group_habit)
    post '/habits/' + group_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + user_token
    }, params: {
      'data': { 'type': 'date', 'attributes': { 'date': Time.zone.now.iso8601 } }
    }
  end

  def undo(user_token, group_habit)
    delete '/habits/' + group_habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + user_token
    }
  end

  def show_group(user_token = @admin_token, group = @group)
    get '/groups/' + group.id.to_s + '/members', headers: {
      'Authorization': 'Bearer ' + user_token
    }
  end
  test 'Fulfillments and undos should impact the leaderboard' do
    fulfill(@admin_token, @easy)
    fulfill(@user1_token, @hard)
    fulfill(@user2_token, @negative)
    # Leaderboard should be: User1: 15, Admin: 5, User3: 0, User2: -10
    show_group
    body = JSON.parse(response.body)
    collection = Group.find(@group.id).memberships.ordered_by_score_and_name.map(&:user)
    body['data'].each_with_index do |user, index|
      assert collection[index].id.to_s == user['id']
    end
    undo(@admin_token, @easy)
    fulfill(@admin_token, @easy)
    undo(@admin_token, @easy)
    fulfill(@admin_token, @easy)
    undo(@user1_token, @hard)
    fulfill(@user2_token, @easy)
    fulfill(@user3_token, @hard)
    fulfill(@user3_token, @easy)
    # Leaderboard should be: User3: 20, Admin: 5, User1: 0, User2: -5
    show_group
    body = JSON.parse(response.body)
    collection = Group.find(@group.id).memberships.ordered_by_score_and_name.map(&:user)
    body['data'].each_with_index do |user, index|
      assert collection[index].id.to_s == user['id']
    end
  end
end
