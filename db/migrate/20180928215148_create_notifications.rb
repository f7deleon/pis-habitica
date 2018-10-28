class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.string :type
      t.integer :sender_id
      t.integer :user_id
      t.belongs_to :request, index: { unique: true }, foreign_key: {on_delete: :cascade}
      t.belongs_to :track_individual_habit, index: { unique: true }, foreign_key: {on_delete: :cascade}
      t.boolean :seen
      
      t.timestamps
    end
  end
end
