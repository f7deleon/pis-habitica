class CreateHabits < ActiveRecord::Migration[5.2]
  def change
    create_table :habits do |t|
      t.string :type
      t.string :name
      t.string :description
      t.integer :difficulty
      t.integer :privacy
      t.integer :frequency
      t.boolean :active
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :group, index: true, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
