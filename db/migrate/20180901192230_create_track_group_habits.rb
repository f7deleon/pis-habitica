# frozen_string_literal: true

class CreateTrackGroupHabits < ActiveRecord::Migration[5.2]
  def change
    create_table :track_group_habits do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :habit, index: true, foreign_key: {on_delete: :cascade}
      t.datetime :date
    end
  end
end
