# frozen_string_literal: true

require 'test_helper'

class IndividualHabitTest < ActiveSupport::TestCase
  def setup
    @user = User.create(
      nickname: 'Example',
      email: 'example@example.com',
      password: 'Example123'
    )
    @individual_type = IndividualType.create(
      user_id: @user.id,
      name: 'Example',
      description: 'Example'
    )
    @individual_habit = IndividualHabit.create(
      user_id: @user.id,
      name: 'Example',
      description: 'Example',
      difficulty: 3,
      privacy: 1,
      active: true,
      frequency: 1
    )
    @user.individual_habits << @individual_habit
    @individual_habit_has_type = IndividualHabitHasType.create(
      habit_id: @individual_habit.id,
      type_id: @individual_type.id
    )
    @individual_habit.individual_habit_has_types << @individual_habit_has_type
    @individual_type.individual_habit_has_types << @individual_habit_has_type
    @track_individual_habit = TrackIndividualHabit.create(
      habit_id: @individual_habit.id,
      date: Time.zone.now
    )
    @individual_habit.track_individual_habits << @track_individual_habit
  end

  test 'should be valid' do
    assert @user.valid?
    assert @individual_type.valid?
    assert @individual_habit.valid?
    assert @individual_habit_has_type.valid?
    assert @track_individual_habit.valid?
  end

  test 'user ID should be present' do
    @individual_habit.user_id = nil
    assert_not @individual_habit.valid?
  end
  test 'active should be present' do
    @individual_habit.active = nil
    assert_not @individual_habit.valid?
  end
  test 'name should be present' do
    @individual_habit.name = ''
    assert_not @individual_habit.valid?
  end
  test 'description is optional' do
    @individual_habit.description = ''
    assert @individual_habit.valid?
  end

  test 'frequency should be present' do
    @individual_habit.frequency = nil
    assert_not @individual_habit.valid?
  end
  test 'frequency should be > 0' do
    @individual_habit.frequency = 0
    assert_not @individual_habit.valid?
  end
  test 'frequency should be < 3' do
    @individual_habit.frequency = 3
    assert_not @individual_habit.valid?
  end

  test 'difficulty should be present' do
    @individual_habit.difficulty = nil
    assert_not @individual_habit.valid?
  end
  test 'difficulty should be > 0' do
    @individual_habit.difficulty = 0
    assert_not @individual_habit.valid?
  end
  test 'difficulty should be < 4' do
    @individual_habit.difficulty = 4
    assert_not @individual_habit.valid?
  end

  test 'privacy should be present' do
    @individual_habit.privacy = nil
    assert_not @individual_habit.valid?
  end
  test 'privacy should be > 0' do
    @individual_habit.privacy = 0
    assert_not @individual_habit.valid?
  end
  test 'privacy should be < 4' do
    @individual_habit.privacy = 4
    assert_not @individual_habit.valid?
  end
end
