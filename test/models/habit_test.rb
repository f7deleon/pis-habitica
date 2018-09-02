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

    @user.save()
    @habit.save()
    @category.save()

    @user_habit = UserHabit.new(habit_id: @habit.id, user_id: @user.id)
    @user_habit.save()
    @user.user_habits << @user_habit
    @habit.user_habits << @user_habit

    
    #@habit_categorie = @habit.habit_categories.new(:categorie_id => @category.id)
    
    #PENDING: Agregar usuario y categoria al habito y hacer los tests de validacion. Tambien hay que ver como validar eso en el modelo
    #@userHabit = UserHabit.new(user: @user.id, habit: @habit.id)
    #@habit.user_habits = [@userHabit]
  end

  test "should be valid" do
    assert @habit.valid?
  end
  test "name should be present" do
    @habit.name = ""
    assert_not @habit.valid?
  end

  test "frecuency should be present" do
    @habit.frecuency = nil
    assert_not @habit.valid?
  end

  test "difficulty should be present" do
    @habit.difficulty = ""
    assert_not @habit.valid?
  end
  test "difficulty should be easy, hard or medium" do
    @habit.difficulty = "facilicimo"
    assert_not @habit.valid?
  end

  test "hasEnd should be present" do
    @habit.hasEnd = nil
    assert_not @habit.valid?
  end

  test "privacy should be present" do
    @habit.privacy = ""
    assert_not @habit.valid?
  end
  test "privacy should be public, private or protected" do
    @habit.privacy = "Kunkka"
    assert_not @habit.valid?
  end

  test "if hasEnd, endDate should be present" do
    @habit.hasEnd = true
    @habit.endDate = nil
    assert_not @habit.valid?
  end

  test "if not hasEnd, should be valid" do
    @habit.hasEnd = false
    @habit.endDate = nil
    assert @habit.valid?
  end

  test "There has to be at least one user_habits (not nil)" do
    @habit.user_habits.clear();
    assert_not @habit.valid?
  end
  #test "categories should be present" do
  #  @habit.categories = nil
  #  assert_not @habit.valid?
  #end

  # Agregar tests por si un habit tiene categorias o usuarios repetidos?
    # Ej: 2 veces la misma categoria
    #     2 veces el mismo usuario tiene ese habito

end
