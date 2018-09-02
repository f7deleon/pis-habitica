# frozen_string_literal: true

class CreateTrackIndividualHabits < ActiveRecord::Migration[5.2]
  def change
    create_table :track_individual_habits, primary_key: %i[individual_habit_id date] do |t|
      t.integer :individual_habit_id, index: true
      t.datetime :date
    end
    # execute "ALTER TABLE track_individual_habits ADD FOREIGN KEY (individual_habit_id,user_id) REFERENCES individual_habits ON DELETE CASCADE;"
  end
end
