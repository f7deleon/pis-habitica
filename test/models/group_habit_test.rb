# frozen_string_literal: true

require 'test_helper'

class GroupHabitTest < ActiveSupport::TestCase
  def setup
    @user = User.create(
      nickname: 'Example',
      email: 'example@example.com',
      password: 'Example123'
    )
    @group = Group.create(
      name: 'Example',
      description: 'Example'
    )
    @user_group = UserGroup.create(
      user_id: @user.id,
      group_id: @group.id
    )
    @user.user_groups << @user_group
    @group.user_groups << @user_group
    @group_type = GroupType.create(
      group_id: @group.id,
      name: 'Example',
      description: 'Example'
    )
    @group_habit = GroupHabit.create(
      group_id: @group.id,
      name: 'Example',
      description: 'Example',
      difficulty: 2,
      privacy: 1,
      frequency: 1
    )
    @group.group_habits << @group_habit
    @group_habit_has_type = GroupHabitHasType.create(
      habit_id: @group_habit.id,
      type_id: @group_type.id
    )
    @group_habit.group_habit_has_types << @group_habit_has_type
    @group_type.group_habit_has_types << @group_habit_has_type
    @track_group_habit = TrackGroupHabit.create(
      user_id: @user.id,
      habit_id: @group_habit.id,
      date: Time.zone.now
    )
    @user.track_group_habits << @track_group_habit
    @group_habit.track_group_habits << @track_group_habit
  end

  test 'should be valid' do
    assert @user.valid?
    assert @group.valid?
    assert @user_group.valid?
    assert @group_type.valid?
    assert @group_habit.valid?
    assert @group_habit_has_type.valid?
    assert @track_group_habit.valid?
  end
  test 'group ID should be present' do
    @group_habit.group_id = nil
    assert_not @group_habit.valid?
  end
  test 'name should be present' do
    @group_habit.name = ''
    assert_not @group_habit.valid?
  end
  test 'frequency should be present' do
    @group_habit.frequency = nil
    assert_not @group_habit.valid?
  end
  test 'frequency should be > 0' do
    @group_habit.frequency = 0
    assert_not @group_habit.valid?
  end
  test 'frequency should be < 3' do
    @group_habit.frequency = 3
    assert_not @group_habit.valid?
  end
  test 'difficulty should be present' do
    @group_habit.difficulty = nil
    assert_not @group_habit.valid?
  end
  test 'difficulty should be > 0' do
    @group_habit.difficulty = 0
    assert_not @group_habit.valid?
  end
  test 'difficulty should be < 4' do
    @group_habit.difficulty = 4
    assert_not @group_habit.valid?
  end
  test 'privacy should be present' do
    @group_habit.privacy = nil
    assert_not @group_habit.valid?
  end
  test 'privacy should be > 0' do
    @group_habit.privacy = 0
    assert_not @group_habit.valid?
  end
  test 'privacy should be < 4' do
    @group_habit.privacy = 4
    assert_not @group_habit.valid?
  end
end
