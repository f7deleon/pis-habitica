class AddPrivacyToGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :privacy, :boolean
  end
end
