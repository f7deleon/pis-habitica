# frozen_string_literal: true

class CreateTrackGroupHabits < ActiveRecord::Migration[5.2]
  def change
    create_table :track_group_habits, primary_key: %i[user_id group_habit_id date] do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.integer :group_habit_id, index: true
      t.datetime :date
    end
    # execute "ALTER TABLE track_group_habits ADD FOREIGN KEY (group_habit_id,group_id) REFERENCES group_habits ON DELETE CASCADE;"
  end
end
