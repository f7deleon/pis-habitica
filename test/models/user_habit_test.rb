require 'test_helper'

class UserHabitTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @category = Category.new(name: "Example Category", description: "Majestuoso")
    @user = User.new(nickname: "Renzo", mail: "renzodgc12@gmail.com", password: "1234")
    @user.save()


    @habit = Habit.new(name: "Example Habit", frecuency: 1,
                     difficulty: "hard", hasEnd: true, privacy: "protected",
                     endDate: Date.new(2018,8,30))
    @habit.save()

    #@user_habit = @user.user_habits.new(:habit_id => @habit.id)
    @user_habit = UserHabit.new(habit_id: @habit.id, user_id: @user.id)
    @user.user_habits << @user_habit
    @habit.user_habits << @user_habit
  end

  test "user_habits be valid" do
    assert @user_habit.valid?
  end


end
