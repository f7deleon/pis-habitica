# frozen_string_literal: true

require 'test_helper'

class ExampleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @user = User.create(nickname: 'Example', mail: 'example@example.com', password: 'Example123')

    @group = Group.create(name: 'Example', description: 'Example')

    @user_group = UserGroup.create(user_id: @user.id, group_id: @group.id)

    @user.user_groups << @user_group
    @group.user_groups << @user_group

    @user_type = Type.create(name: "Example", description: "Example")
    @individual_type = IndividualType.create(user_id: @user.id, type_id: @user_type.id)

    @user.individual_types << @individual_type
  

    @individual_habit = IndividualHabit.create(
      user_id: @user.id,
      name: 'Example',
      description: 'Example',
      dificulty: 3,
      privacy: 1,
      frecuency: 1
    )

    @user.individual_habits << @individual_habit

    @type_group = Type.create(name: "example", description: "example")
    @group_type = GroupType.create(group_id: @group.id,type_id: @type_group.id)

    @group.group_types << @group_type

    @group_habit = GroupHabit.create(
      group_id: @group.id,
      name: 'Example',
      description: 'Example',
      dificulty: 2,
      privacy: 1,
      frecuency: 1
    )

    @group.group_habits << @group_habit

    @individual_habit_has_type = IndividualHabitHasType.create(individual_habit_id: @individual_habit.id, type_id: @individual_type.type_id)

    @group_habit_has_type = GroupHabitHasType.create(
      group_habit_id: @group_habit.id,
      type_id: @group_type.type_id
    )

    @group_habit.group_habit_has_types << @group_habit_has_type
    @type_group.group_habit_has_types << @group_habit_has_type 

    @individual_habit.individual_habit_has_types << @individual_habit_has_type
    @user_type.individual_habit_has_types << @individual_habit_has_type

    @track_individual_habit = TrackIndividualHabit.create(individual_habit_id: @individual_habit.id, date: Time.zone.now)
    @individual_habit.track_individual_habits << @track_individual_habit

    @track_group_habit = TrackGroupHabit.create(user_id: @user.id, group_habit_id: @individual_habit.id, date: Time.zone.now)
    @user.track_group_habits << @track_group_habit
    @group_habit.track_group_habits << @track_group_habit
  end

  test 'should be valid' do
    assert @user.valid?
    assert @group.valid?
    assert @user_group.valid?
    assert @individual_type.valid?
    assert @individual_habit.valid?
    assert @group_type.valid?
    assert @group_habit.valid?
    assert @group_habit_has_type.valid?
    assert @individual_habit_has_type.valid?
    assert @track_group_habit.valid?
    assert @track_individual_habit.valid?
  end
end
