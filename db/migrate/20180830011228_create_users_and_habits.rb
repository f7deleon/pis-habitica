class CreateUsersAndHabits < ActiveRecord::Migration[5.2]
  def change
    create_table :users_and_habits, :primary_key => [:user_id, :habit_id] do |t|
    	t.belongs_to :user, index: true, foreign_key: 'key_user_to_habit'
    	t.belongs_to :habit, index: true, foreign_key: 'key_habit_to_user'

    	t.timestamps
    end
  end
end
