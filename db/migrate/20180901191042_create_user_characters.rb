# frozen_string_literal: true

class CreateUserCharacters < ActiveRecord::Migration[5.2]
  def change
    create_table :user_characters, primary_key: %i[user_id character_id creation_date] do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :character, index: true, foreign_key: true
      t.boolean :is_alive
      t.datetime :creation_date
    end
  end
end
