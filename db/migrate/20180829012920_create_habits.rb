class CreateHabits < ActiveRecord::Migration[5.2]
  def change
    create_table :habits do |t|
      t.string :name
      t.integer :frecuency
      t.string :difficulty
      t.boolean :hasEnd
      t.string :privacy
      t.date :endDate

      t.timestamps
    end
  end
end
