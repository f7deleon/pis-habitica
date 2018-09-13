# frozen_string_literal: true

require 'test_helper'

class GroupHabitTest < ActiveSupport::TestCase
  def setup
    @user = User.create(
      nickname: 'Example',
      mail: 'example@example.com',
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
    @user_type = Type.create(name: 'Example', description: 'Example')
    @type_group = Type.create(name: 'example', description: 'example')
    @group_type = GroupType.create(
      group_id: @group.id,
      type_id: @type_group.id
    )
    @group.group_types << @group_type
    @group_habit = GroupHabit.create(
      group_id: @group.id,
      name: 'Example',
      description: 'Example',
      difficulty: 2,
      privacy: 1,
      frecuency: 1
    )
    @group.group_habits << @group_habit
    @group_habit_has_type = GroupHabitHasType.create(
      group_habit_id: @group_habit.id,
      type_id: @group_type.type_id
    )
    @group_habit.group_habit_has_types << @group_habit_has_type
    @type_group.group_habit_has_types << @group_habit_has_type
    @track_group_habit = TrackGroupHabit.create(
      user_id: @user.id,
      group_habit_id: @group_habit.id,
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
  test 'frecuency should be present' do
    @group_habit.frecuency = nil
    assert_not @group_habit.valid?
  end
  test 'frecuency should be > 0' do
    @group_habit.frecuency = 0
    assert_not @group_habit.valid?
  end
  test 'frecuency should be < 3' do
    @group_habit.frecuency = 3
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
