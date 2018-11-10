class AddScoreDifferenceToTrackGroupHabits < ActiveRecord::Migration[5.2]
  def change
    add_column :track_group_habits, :score_difference, :integer
  end
end
