# frozen_string_literal: true

class CreateTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :types do |t|
      t.string :name
      t.string :description
    end
  end
end
