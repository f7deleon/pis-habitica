# frozen_string_literal: true

class CreateUserGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :user_groups, primary_key: %i[user_id group_id] do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :group, index: true, foreign_key: true

      t.timestamps
    end
  end
end
