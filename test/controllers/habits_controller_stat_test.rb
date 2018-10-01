# frozen_string_literal: true

require 'test_helper'

class HabitsControllerStatTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'Example', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        'password': @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']
    @individual_habit = IndividualHabit.create(
      user_id: @user.id,
      name: 'Example',
      description: 'Example',
      difficulty: 3,
      privacy: 1,
      frequency: 2,
      active: true
    )
    @user.individual_habits << @individual_habit
    ## julio

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 7, 6)
    )
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 7, 7)
    )
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 7, 17)
    )
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 7, 23)
    )
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 7, 28)
    )
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 7, 17)
    )
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 7, 23)
    )
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 7, 28)
    )
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    ## agosto
    @tracks_id = []
    tracks = []
    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 8, 1)
    )
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 8, 2)
    )
    tracks << @track_individual_habit
    @tracks_id << @track_individual_habit.id
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 8, 3)
    )
    tracks << @track_individual_habit
    @tracks_id << @track_individual_habit.id
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 8, 4)
    )
    tracks << @track_individual_habit
    @tracks_id << @track_individual_habit.id
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 8, 5)
    )
    tracks << @track_individual_habit
    @tracks_id << @track_individual_habit.id
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 8, 6)
    )
    tracks << @track_individual_habit
    @tracks_id << @track_individual_habit.id
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 8, 7)
    )
    tracks << @track_individual_habit
    @tracks_id << @track_individual_habit.id
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 8, 28)
    )
    tracks << @track_individual_habit
    @tracks_id << @track_individual_habit.id
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 8, 17)
    )
    tracks << @track_individual_habit
    @tracks_id << @track_individual_habit.id
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 8, 23)
    )
    tracks << @track_individual_habit
    @tracks_id << @track_individual_habit.id
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 8, 28)
    )
    tracks << @track_individual_habit
    @tracks_id << @track_individual_habit.id
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    ## septiembre
    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 9, 1)
    )
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 9, 2)
    )
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 9, 3)
    )
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 9, 4)
    )
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 9, 5)
    )
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 9, 7)
    )
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.new(2018, 9, 8)
    )
    @individual_habit.track_individual_habits << @track_individual_habit
    @user.individual_habits << @individual_habit

    @expected = StatsSerializer.json(@individual_habit, 6, 0, 100, 23.333)
  end
  test 'VerEstadisticas' do
    get '/me/habits/' + @individual_habit.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    assert @expected.to_json == response.body
  end
end
