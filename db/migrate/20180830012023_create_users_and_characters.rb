class CreateUsersAndCharacters < ActiveRecord::Migration[5.2]
  def change
    create_table :users_and_characters, :primary_key => [:user_id, :character_id] do |t|
    	t.belongs_to :user, index: true, foreign_key: 'key_user_to_character'
    	t.belongs_to :character, index: true, foreign_key: 'key_character_to_user'
    	t.boolean :active 

    	t.timestamps
    end
  end
end
