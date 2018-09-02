# frozen_string_literal: true

class CreateGroupTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :group_types, primary_key: %i[type_id group_id] do |t|
      t.belongs_to :type, index: true, foreign_key: true
      t.belongs_to :group, index: true, foreign_key: true
    end
  end
end
