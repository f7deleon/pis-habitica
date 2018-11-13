# frozen_string_literal: true

require 'test_helper'

class HabitControllerGroupCreateTest < ActionDispatch::IntegrationTest
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

    @groupless_user = User.create(nickname: 'groupless_user', email: 'groupless@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @groupless_user.email,
        'password': @groupless_user.password
      }
    }
    @groupless_user_token = JSON.parse(response.body)['jwt']

    @group = Group.create(name: 'Grupo', description: 'Propio grupo', privacy: false)

    @membership1 = Membership.create(user_id: @user.id, group_id: @group.id, admin: true)
    @membership2 = Membership.create(user_id: @user2.id, group_id: @group.id, admin: false)

    @default_type = DefaultType.create(
      user_id: @user.id,
      name: 'Example',
      description: 'Example'
    )
  end

  test 'is valid' do
    assert @user.valid?
    assert @user2.valid?
    assert @groupless_user.valid?
    assert @group.valid?
    assert @default_type.valid?
    assert @membership1.valid?
    assert @membership2.valid?
  end

  test 'AltaHabitoGrupo: should create habit' do
    post '/habits', headers: { 'Authorization': 'Bearer ' + @user_token }, params: {
      'data': { 'type': 'group_habit',
                'attributes':
                  { 'name': 'Example', 'description': 'Example', 'frequency': 1, 'difficulty': 1 },
                'relationships': {
                  'types': [
                    { 'data': { 'id': @default_type.id, 'type': 'type' } }
                  ],
                  'group': { 'id': @group.id, 'type': 'group' }
                } }
    }
    expected = {
      'data': { 'id': JSON.parse(response.body)['data']['id'], 'type': 'group_habit',
                'attributes':
                { 'name': 'Example', 'description': 'Example', 'difficulty': 1, 'privacy': 1, 'frequency': 1,
                  'negative': false, "count_track": 0 },
                'relationships': {
                  'types': {
                    'data': [{ 'id': @default_type.id.to_s, 'type': 'type' }]
                  }
                } }
    }

    assert_equal 201, status
    assert expected.to_json == response.body
  end

  test 'AltaHabitoGrupo: should be a member to create' do
    post '/habits', headers: { 'Authorization': 'Bearer ' + @groupless_user_token }, params: {
      'data': { 'type': 'group_habit',
                'attributes':
                    { 'name': 'Example', 'description': 'Example', 'frequency': 1, 'difficulty': 1, 'privacy': 1 },
                'relationships': {
                  'types': [
                    { 'data': { 'id': @default_type.id, 'type': 'type' } }
                  ],
                  'group': { 'id': @group.id, 'type': 'group' }
                } }
    }
    assert_equal 403, status # Forbidden
  end

  test 'AltaHabitoGrupo: bad token' do
    post '/habits', headers: { 'Authorization': 'Bearer malotoken' }, params: {
      'data': { 'type': 'group_habit',
                'attributes':
                    { 'name': 'Example', 'description': 'Example', 'frequency': 1, 'difficulty': 1, 'privacy': 1 },
                'relationships': {
                  'types': [
                    { 'data': { 'id': @default_type.id, 'type': 'type' } }
                  ],
                  'group': { 'id': @group.id, 'type': 'group' }
                } }
    }
    assert_equal 401, status
  end

  test 'AltaHabitoGrupo: bad request' do
    post '/habits', headers: { 'Authorization': 'Bearer ' + @user_token }, params: {
      'data': { 'type': 'group_habit',
                'attributes':
                    { 'title': 'Example', 'description': 'Example', 'frequency': 1, 'difficulty': 1, 'privacy': 1 },
                'relationships': {
                  'types': [
                    { 'data': { 'id': @default_type.id, 'type': 'type' } }
                  ],
                  'group': { 'id': @group.id, 'type': 'group' }
                } }
    }
    assert_equal 400, status
  end

  test 'AltaHabitoGrupo: not exist type' do
    post '/habits', headers: { 'Authorization': 'Bearer ' + @user_token }, params: {
      'data': { 'type': 'group_habit',
                'attributes':
                    { 'name': 'Example', 'description': 'Example', 'frequency': 1, 'difficulty': 1, 'privacy': 1 },
                'relationships': {
                  'types': [
                    { 'data': { 'id': 10_001, 'type': 'type' } }
                  ],
                  'group': { 'id': @group.id, 'type': 'group' }
                } }
    }
    assert_equal 404, status
  end

  test 'should be admin to create' do
    post '/habits', headers: { 'Authorization': 'Bearer ' + @user2_token }, params: {
      'data': { 'type': 'group_habit',
                'attributes':
                  { 'name': 'Example', 'description': 'Example', 'frequency': 1, 'difficulty': 1, 'privacy': 1 },
                'relationships': {
                  'types': [
                    { 'data': { 'id': @default_type.id, 'type': 'type' } }
                  ],
                  'group': { 'id': @group.id, 'type': 'group' }
                } }
    }
    assert_equal 403, status # Forbidden
  end
end
