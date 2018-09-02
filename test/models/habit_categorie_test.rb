require 'test_helper'

class HabitCategorieTest < ActiveSupport::TestCase
  def setup
    @category = Category.new(name: "Example Category", description: "Majestuoso")
    @category.save()
    
    @habit = Habit.new(name: "Example Habit", frecuency: 1,
                     difficulty: "hard", hasEnd: true, privacy: "protected",
                     endDate: Date.new(2018,8,30))
    @habit.save()

    @habit_categorie = HabitCategorie.new(habit_id: @habit.id, category_id: @category.id)
    @category.habit_categories << @habit_categorie
    @habit.habit_categories << @habit_categorie
  end
  #FIXME: Arreglar el lio de ie vs y

  #test "habit_categorie be valid" do
  #  assert @habit_categorie.valid?
  #end

end
