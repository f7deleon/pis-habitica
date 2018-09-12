# frozen_string_literal: true

require 'test_helper'

class HabitsControllerCreateTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(
      nickname: 'Example',
      email: 'example@example.com',
      password: 'Example123'
    )
    @user2 = User.create(
      nickname: 'Example12',
      email: 'example12@example.com',
      password: 'Example123'
    )

    @individual_type = IndividualType.create(
      user_id: @user.id,
      name: 'Example',
      description: 'Example'
    )
    @individual_type2 = IndividualType.create(
      user_id: @user.id,
      name: 'Example',
      description: 'Example'
    )
  end

  test 'should be valid' do
    assert @user.valid?
    assert @individual_type.valid?
    assert @individual_type2.valid?
  end
  test 'AltaHabito: should create habit' do
    post '/me/habits?token=' + @user.id.to_s, params: {
      'data': {
        'type': 'habit',
        'attributes': {
          'name': 'Example',
          'description': 'Example',
          'frequency': 1,
          'difficulty': 1,
          'privacy': 1
        },
        'relationships': {
          'types': [
            { 'data': { 'id': @individual_type.id, 'type': 'type' } },
            { 'data': { 'id': @individual_type2.id, 'type': 'type' } }
          ]
        }
      }
    }
    assert_equal 201, status # Created
  end
  test 'AltaHabito: User should exist' do
    post '/me/habits?token=999999999', params: {
      'data': {
        'type': 'habit',
        'attributes': {
          'name': 'Example',
          'description': 'Example',
          'frequency': 1,
          'difficulty': 1,
          'privacy': 1
        },
        'relationships': {
          'types': [
            { 'data': { 'id': @individual_type.id, 'type': 'type' } },
            { 'data': { 'id': @individual_type2.id, 'type': 'type' } }
          ]
        }
      }
    }
    assert_equal 403, status # Forbbiden
  end
  test 'AltaHabito: Type should exist' do
    post '/me/habits?token=' + @user.id.to_s, params: {
      'data': {
        'type': 'habit',
        'attributes': {
          'name': 'Example',
          'description': 'Example',
          'frequency': 1,
          'difficulty': 1,
          'privacy': 1
        },
        'relationships': {
          'types': [
            'data': {
              'id': 99_999_999,
              'type': 'type'
            }
          ]
        }
      }
    }
    assert_equal 404, status # Not Found
  end
end
