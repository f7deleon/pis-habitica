# frozen_string_literal: true

require 'test_helper'

class HabitsControllerStatTest < ActionDispatch::IntegrationTest
  def load_not_frequency(date, save_month)
    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: date,
      health_difference: 0
    )
    @months_id << @track_individual_habit if save_month
  end

  def load_frequency(date)
    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit_frequency.id,
      date: date,
      health_difference: 0
    )
  end

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
      frequency: 1,
      active: true
    )
    @individual_habit_frequency = IndividualHabit.create(
      user_id: @user.id,
      name: 'Example',
      description: 'Example',
      difficulty: 3,
      privacy: 1,
      frequency: 2,
      active: true
    )

    @individual_habit_frequency.update(created_at: '2018-08-27 22:17:20')

    ## sin frecuencia--------------------------------------------------
    @months_id = []

    # junio
    @month = []
    load_not_frequency Time.new(2018, 6, 6), false

    # julio

    load_not_frequency Time.new(2018, 7, 7), true
    load_not_frequency Time.new(2018, 7, 17), true
    load_not_frequency Time.new(2018, 7, 17), false
    load_not_frequency Time.new(2018, 7, 23), true
    load_not_frequency Time.new(2018, 7, 23), false
    load_not_frequency Time.new(2018, 7, 28), true
    load_not_frequency Time.new(2018, 7, 28), false

    ## agosto
    load_not_frequency Time.new(2018, 8, 1), true
    load_not_frequency Time.new(2018, 8, 2), true
    load_not_frequency Time.new(2018, 8, 3), true
    load_not_frequency Time.new(2018, 8, 4), true
    load_not_frequency Time.new(2018, 8, 5), true
    load_not_frequency Time.new(2018, 8, 6), true
    load_not_frequency Time.new(2018, 8, 7), true
    load_not_frequency Time.new(2018, 8, 17), true
    load_not_frequency Time.new(2018, 8, 23), true
    load_not_frequency Time.new(2018, 8, 28), true
    load_not_frequency Time.new(2018, 8, 28), false

    ## septiembre
    load_not_frequency Time.new(2018, 9, 1), true
    load_not_frequency Time.new(2018, 9, 2), true
    load_not_frequency Time.new(2018, 9, 3), true
    load_not_frequency Time.new(2018, 9, 4), true
    load_not_frequency Time.new(2018, 9, 5), true
    load_not_frequency Time.new(2018, 9, 7), true
    load_not_frequency Time.new(2018, 9, 7), false
    load_not_frequency Time.new(2018, 9, 8), true

    ## con frecuencia--------------------------------------------------

    # agosto
    load_frequency Time.new(2018, 8, 28)

    ## septiembre
    load_frequency Time.new(2018, 9, 1)
    load_frequency Time.new(2018, 9, 2)
    load_frequency Time.new(2018, 9, 3)
    load_frequency Time.new(2018, 9, 4)
    load_frequency Time.new(2018, 9, 5)
    load_frequency Time.new(2018, 9, 7)
    load_frequency Time.new(2018, 9, 8)

    @month = [
      {
        "id": @months_id[0].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[0].date,
        "count_track": 1
      },
      {
        "id": @months_id[1].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[1].date,
        "count_track": 2
      },
      {
        "id": @months_id[2].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[2].date,
        "count_track": 2
      },
      {
        "id": @months_id[3].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[3].date,
        "count_track": 2
      },
      {
        "id": @months_id[4].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[4].date,
        "count_track": 1
      },
      {
        "id": @months_id[5].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[5].date,
        "count_track": 1
      },
      {
        "id": @months_id[6].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[6].date,
        "count_track": 1
      },
      {
        "id": @months_id[7].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[7].date,
        "count_track": 1
      },
      {
        "id": @months_id[8].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[8].date,
        "count_track": 1
      },
      {
        "id": @months_id[9].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[9].date,
        "count_track": 1
      },
      {
        "id": @months_id[10].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[10].date,
        "count_track": 1
      },
      {
        "id": @months_id[11].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[11].date,
        "count_track": 1
      },
      {
        "id": @months_id[12].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[12].date,
        "count_track": 1
      },
      {
        "id": @months_id[13].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[13].date,
        "count_track": 2
      },
      {
        "id": @months_id[14].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[14].date,
        "count_track": 1
      },
      {
        "id": @months_id[15].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[15].date,
        "count_track": 1
      },
      {
        "id": @months_id[16].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[16].date,
        "count_track": 1
      },
      {
        "id": @months_id[17].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[17].date,
        "count_track": 1
      },
      {
        "id": @months_id[18].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[18].date,
        "count_track": 1
      },
      {
        "id": @months_id[19].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[19].date,
        "count_track": 2
      },
      {
        "id": @months_id[20].id,
        "habit_id": @individual_habit.id,
        "date": @months_id[20].date,
        "count_track": 1
      }
    ]

    # se calcula porcentaje esperado
    days = TimeDifference.between('2018-08-27 22:17:20'.to_date, Time.zone.now).in_days.round + 1
    percent = (8.to_f / days) * 100

    data_frequency = { "max": 5,
                       "successive": 0,
                       "percent": percent.truncate,
                       "calendar": [],
                       "months": [] }

    data_not_frequency = { "max": 0,
                           "successive": 0,
                           "percent": 0,
                           "calendar": [],
                           "months": @month }

    @expected_frequency = StatsSerializer.json(data_frequency, @individual_habit_frequency)
    @expected_not_frequency = StatsSerializer.json(data_not_frequency, @individual_habit)
  end
  test 'VerEstadisticasNotFrequency' do
    get '/me/habits/' + @individual_habit.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    assert @expected_not_frequency.to_json == response.body
  end
  test 'VerEstadisticasFrequency' do
    get '/me/habits/' + @individual_habit_frequency.id.to_s, headers: {
      'Authorization': 'Bearer ' + @user_token
    }
    # por la diferencia de tiempo el porcentaje da distinto, por eso se hace el redondeo
    salida = JSON.parse(response.body)
    percent = salida['included'][0]['attributes']['stat']['data']['percent'].truncate
    salida['included'][0]['attributes']['stat']['data']['percent'] = percent - 1
    assert @expected_frequency.to_json == JSON.generate(salida)
  end
end
