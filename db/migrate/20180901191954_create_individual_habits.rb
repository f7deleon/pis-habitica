# frozen_string_literal: true

class CreateIndividualHabits < ActiveRecord::Migration[5.2]
  def change
    create_table :individual_habits, primary_key: %i[id user_id] do |t|
      t.bigserial :id, index: true
      t.belongs_to :user, index: true, foreign_key: true
      t.string :name
      t.string :description
      t.integer :difficulty
      t.integer :privacy
      t.integer :frequency

      t.timestamps
    end
  end
end
