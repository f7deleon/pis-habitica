# frozen_string_literal: true

require 'test_helper'

class HabitsControllerGroupDeathTest < ActionDispatch::IntegrationTest
  def setup
    @user1 = User.create(nickname: 'Example1', email: 'example1@example.com', password: 'Example123')
    @user_token1 = sign_in(@user1)
    @user2 = User.create(nickname: 'Example2', email: 'example2@example.com', password: 'Example123')
    @user_token2 = sign_in(@user2)

    @group = Group.create(name: 'example', privacy: true)
    @membership1 = Membership.create(user_id: @user1.id, group_id: @group.id, admin: true)
    @membership2 = Membership.create(user_id: @user2.id, group_id: @group.id, admin: false)

    @user1_neg_habit = IndividualHabit.create(
      user_id: @user1.id,
      name: 'Example',
      description: 'Example',
      difficulty: 1,
      privacy: 1,
      frequency: 1,
      active: true,
      negative: true
    )

    @group_habit = GroupHabit.create(
      group_id: @group.id,
      name: 'Example',
      description: 'Example',
      difficulty: 3,
      privacy: 1,
      frequency: 1,
      active: true,
      negative: false
    )
    @group_negative_habit = GroupHabit.create(
      group_id: @group.id,
      name: 'Example',
      description: 'Example',
      difficulty: 1,
      privacy: 1,
      frequency: 1,
      active: true,
      negative: true
    )
    @char = Character.create(name: 'Mago', description: I18n.t('mage_description'))
    add_char(@user_token1)
    add_char(@user_token2)
  end

  def sign_in(user)
    post '/user_token', params: {
      'auth': {
        'email': user.email,
        'password': user.password
      }
    }
    JSON.parse(response.body)['jwt']
  end

  def add_char(token, char = @char)
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + token
    }, params: {
      'data': {
        'id': char.id.to_s,
        'type': 'characters',
        'attributes': { 'name': 'Mago', 'description': I18n.t('mage_description') }
      },
      'included': [{ 'type': 'date', 'attributes': { 'date': '2018-09-07T12:00:00Z' } }]
    }
  end

  def fulfill(habit, token, date = Time.zone.now.iso8601)
    post '/habits/' + habit.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + token
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': date } } }
  end

  test 'should be valid' do
    assert @user1.valid?
    assert @user2.valid?

    assert @group.valid?

    assert @char.valid?

    assert @group_habit.valid?
    assert @group_negative_habit.valid?
    assert @user1_neg_habit.valid?

    assert @membership1.valid?
    assert @membership2.valid?
  end

  test 'If you die and had score > 0 in some group -> score == 0' do
    3.times do
      fulfill(@group_habit, @user_token1)
      assert_equal 201, status # Created
    end
    @user1.health = 1
    @user1.save!
    fulfill(@user1_neg_habit, @user_token1)

    assert_equal 201, status # Created
    body = JSON.parse(response.body)
    user = User.find(@user1.id)
    assert body['data']['attributes']['is_dead']
    assert_equal(user.experience, 0)
    assert user.dead?

    assert user.memberships.find_by(group_id: @group.id).score.zero?
    assert user.track_group_habits.empty?
  end

  test 'If you die and had score < 0 in some group -> score stays the same' do
    @user1.health = 1
    @user1.save!
    fulfill(@group_negative_habit, @user_token1)

    assert_equal 201, status # Created
    body = JSON.parse(response.body)
    user = User.find(@user1.id)
    assert body['data']['attributes']['is_dead']
    assert_equal(user.experience, 0)
    assert user.dead?

    assert user.memberships.find_by(group_id: @group.id).score.eql? @group_negative_habit.score_difference
    assert user.track_group_habits.empty?
  end
end
