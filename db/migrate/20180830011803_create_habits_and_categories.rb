class CreateHabitsAndCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :habit_categories, :primary_key => [:habit_id, :category_id] do |t|
    	t.belongs_to :habit, index: true, foreign_key: 'key_habit_to_category'
    	t.belongs_to :category, index: true, foreign_key: 'key_category_to_habit'

    	t.timestamps
    end
  end
end
