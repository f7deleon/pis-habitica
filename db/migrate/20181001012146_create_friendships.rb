class CreateFriendships < ActiveRecord::Migration[5.2]
  def change
    create_table :friendships do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.references :friend
      t.timestamps
    end
  end
end