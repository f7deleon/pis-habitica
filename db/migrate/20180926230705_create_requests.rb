class CreateRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :requests do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.references :receiver
      t.timestamps
    end
  end
end
