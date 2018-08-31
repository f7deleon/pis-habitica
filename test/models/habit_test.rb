require 'test_helper'

class HabitTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @category = Category.new(name: "Example Category", description: "Majestuoso")
    @user = User.new(nickname: "Renzo", mail: "renzodgc12@gmail.com", password: "1234")
    @habit = Habit.new(name: "Example Habit", frecuency: 1,
                     difficulty: "hard", hasEnd: true, privacy: "protected",
                     endDate: Date.new(2018,8,30))
  end

  test "should be valid" do
    assert @habit.valid?
  end

end
