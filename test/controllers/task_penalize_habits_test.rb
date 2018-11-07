# frozen_string_literal: true

require 'test_helper'
require 'rake'
load './lib/tasks/penalize_habits.rake'

class TaskPenalizeHabitsTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'Demogorgon', email: 'demo@demo.com', password: '12341234')

    @user2 = User.create(nickname: 'Demogorgon2', email: 'demo2@demo.com', password: '12341234')

    @user3 = User.create(nickname: 'Demogorgon3', email: 'demo3@demo.com', password: '12341234')

    character = Character.create(name: 'Mago', description: I18n.t('mage_description'))

    from_date = Date.new(2018, 9, 1)

    from_date =
      @user.add_character(character.id, from_date)
    @user2.add_character(character.id, from_date)
    @user3.add_character(character.id, from_date)

    @user2.death

    @habit = IndividualHabit.create(
      user_id: @user.id,
      name: 'habito diario',
      description: 'diario',
      difficulty: 2,
      privacy: 1,
      frequency: 2,
      created_at: from_date
    )

    IndividualHabit.create(
      user_id: @user2.id,
      name: 'habito diario',
      description: 'diario',
      difficulty: 2,
      privacy: 1,
      frequency: 2,
      created_at: from_date
    )

    @habit2 = IndividualHabit.create(
      user_id: @user3.id,
      name: 'habito diario',
      description: 'diario',
      difficulty: 2,
      privacy: 1,
      frequency: 2,
      created_at: from_date
    )

    # rubocop:disable Style/DateTime:
    @habit2.track_individual_habits.create(date: DateTime.yesterday.change(hour: 23, min: 59, sec: 0))
    # rubocop:enable Style/DateTime:

    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        "password": @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']
    Rake::Task['penalize_habits'].execute
  end

  test 'Get both types of notification of @user' do
    result = get '/me/notifications?type=', headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert body['data'].length == 1
  end

  test 'rake task executed and user alive' do
    assert PenalizeNotification.find_by(receiver: @user)
    assert_equal(User.find(@user.id).health, @user.max_health + @habit.decrement_of_health(@user))
  end

  test 'rake task executed user dead' do
    assert PenalizeNotification.find_by(receiver: @user2).nil?
  end

  test 'rake tast fullfil 23:59' do
    assert User.find(@user3.id).health == @user3.max_health
  end
end
