class CreateUsersAndCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :user_categories, :primary_key => [:user_id, :category_id] do |t|
    	t.belongs_to :user, index: true, foreign_key: 'key_user_to_category'
    	t.belongs_to :category, index: true, foreign_key: 'key_category_to_user'

    	t.timestamps
    end
  end
end
