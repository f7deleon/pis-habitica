class AddNegativeToHabits < ActiveRecord::Migration[5.2]
  def change
    add_column :habits, :negative, :boolean
  end
end
