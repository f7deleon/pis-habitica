# frozen_string_literal: true

class CreateGroupHabitHasTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :group_habit_has_types do |t|
      t.belongs_to :habit, index: true, foreing_key: true
      t.belongs_to :type, index: true, foreing_key: true
    end
  end
end
