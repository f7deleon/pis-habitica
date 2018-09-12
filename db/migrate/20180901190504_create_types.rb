# frozen_string_literal: true

class CreateTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :types do |t|
      t.string :type
      t.string :name
      t.string :description
      t.belongs_to :group, index: true, foreign_key: true
      t.belongs_to :user, index: true, foreign_key: true
    end
  end
end
