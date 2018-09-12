# frozen_string_literal: true

require 'test_helper'

class HabitsControllerFulfillTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'Example', email: 'example@example.com', password: 'Example123')
    @user2 = User.create(nickname: 'Example12', email: 'example12@example.com', password: 'Example123')
    @individual_type = IndividualType.create(user_id: @user.id, name: 'Example', description: 'Example')
    @individual_type2 = IndividualType.create(user_id: @user.id, name: '2', description: '2')
    @individual_habit_to_track = IndividualHabit.create(
      user_id: @user.id,
      name: 'Example',
      description: 'Example',
      difficulty: 3,
      privacy: 1,
      frequency: 1
    )
    @user.individual_habits << @individual_habit_to_track
    @individual_habit_has_type = IndividualHabitHasType.create(
      habit_id: @individual_habit_to_track.id,
      type_id: @individual_type.id
    )
    @individual_habit_to_track.individual_habit_has_types << @individual_habit_has_type
    @individual_type.individual_habit_has_types << @individual_habit_has_type
    # If Habit frequency is daily habit must not have been fulfilled today
    @user3 = User.create(nickname: 'Example123', email: 'example123@example.com', password: '112312312323')
    @individual_type3 = IndividualType.create(user_id: @user3.id, name: 'Example', description: 'Example')
    @user3.individual_types << @individual_type3

    @individual_habit_already_tracked = IndividualHabit.create(
      user_id: @user3.id,
      name: 'Example',
      description: 'Example',
      difficulty: 3,
      privacy: 1,
      frequency: 2
    )
    @user3.individual_habits << @individual_habit_already_tracked
    @individual_habit_has_type3 = IndividualHabitHasType.create(
      habit_id: @individual_habit_already_tracked.id,
      type_id: @individual_type3.id
    )
    @individual_habit_already_tracked.individual_habit_has_types << @individual_habit_has_type3
    @individual_type3.individual_habit_has_types << @individual_habit_has_type3
    @track_individual_habit3 = TrackIndividualHabit.create(
      habit_id: @individual_habit_already_tracked.id,
      date: Time.zone.now
    )
    @individual_habit_already_tracked.track_individual_habits << @track_individual_habit3
  end
  test 'should be valid' do
    assert @user.valid?
    assert @individual_type.valid?
    assert @individual_type2.valid?
  end
  test 'CumplirHabito: should track habit' do
    post '/me/habits/fulfill?token=' + @user.id.to_s, params: {
      'data': {
        'id': @individual_habit_to_track.id,
        'type': 'habits',
        'relationships': [
          {
            'track-individual-habits': {
              'data': {
                'type': 'track-individual-habits',
                'attributes': {
                  'date': '2018-09-05T21:39:27+00:00'
                }
              }
            }
          }
        ]
      }
    }
    assert_equal 201, status # Created
  end
  test 'CumplirHabito: User should exist' do
    post '/me/habits/fulfill?token=999999999', params: {
      'data': {
        'id': @individual_habit_to_track.id,
        'type': 'habits',
        'relationships': [
          {
            'track-individual-habits': {
              'data': {
                'type': 'track-individual-habits',
                'attributes': {
                  'date': '2018-09-05T21:39:27+00:00'
                }
              }
            }
          }
        ]
      }
    }
    assert_equal 403, status # Forbbiden
  end
  test 'CumplirHabito: User should have this habit' do
    post '/me/habits/fulfill?token=' + @user2.id.to_s, params: {
      'data': {
        'id': @individual_habit_to_track.id,
        'type': 'habits',
        'relationships': [
          {
            'track-individual-habits': {
              'data': {
                'type': 'track-individual-habits',
                'attributes': {
                  'date': '2018-09-05T21:39:27+00:00'
                }
              }
            }
          }
        ]
      }
    }
    assert_equal 404, status # :bad_request
  end
  test 'CumplirHabito: If Habit frequency is daily habit must not have been fulfilled today' do
    post '/me/habits/fulfill?token=' + @user3.id.to_s, params: {
      'data': {
        'id': @individual_habit_already_tracked.id,
        'type': 'habits',
        'relationships': [
          {
            'track-individual-habits': {
              'data': {
                'type': 'track-individual-habits',
                'attributes': {
                  'date': Time.zone.now.iso8601
                }
              }
            }
          }
        ]
      }
    }
    assert_equal 409, status # :conflict
  end
  test 'CumplirHabito: Date should be in ISO 8601' do
    post '/me/habits/fulfill?token=' + @user.id.to_s, params: {
      'data': {
        'id': @individual_habit_to_track.id,
        'type': 'habits',
        'relationships': [
          {
            'track-individual-habits': {
              'data': {
                'type': 'track-individual-habits',
                'attributes': {
                  'date': Time.now.rfc2822
                }
              }
            }
          }
        ]
      }
    }
    assert_equal 400, status # :bad_request
  end
end
