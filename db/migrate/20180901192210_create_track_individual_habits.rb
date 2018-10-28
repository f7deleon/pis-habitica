# frozen_string_literal: true

class CreateTrackIndividualHabits < ActiveRecord::Migration[5.2]
  def change
    create_table :track_individual_habits do |t|
      t.belongs_to :habit, index: true, foreign_key: true
      t.integer :health_difference
      t.integer :experience_difference
      t.datetime :date
    end
  end
end
