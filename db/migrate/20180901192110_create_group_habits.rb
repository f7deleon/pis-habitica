# frozen_string_literal: true

class CreateGroupHabits < ActiveRecord::Migration[5.2]
  def change
    create_table :group_habits, primary_key: %i[id group_id] do |t|
      t.serial :id, index: true
      t.belongs_to :group, index: true, foreign_key: true
      t.string :name
      t.string :description
      t.integer :difficulty
      t.integer :privacy
      t.integer :frecuency

      t.timestamps
    end
  end
end
