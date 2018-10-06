class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.string :type
      t.integer :sender_id
      t.integer :user_id
      t.belongs_to :request
      t.boolean :seen

      t.timestamps
    end
  end
end
