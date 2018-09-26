# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :nickname
      t.string :email
      t.string :password

      t.timestamps
    end
    add_column :users, :password_digest, :string
  end
end
