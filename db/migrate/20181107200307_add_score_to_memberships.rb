class AddScoreToMemberships < ActiveRecord::Migration[5.2]
  def change
    add_column :memberships, :score, :integer
  end
end
