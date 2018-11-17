class AddHealthExperienceToTrackGroupHabit < ActiveRecord::Migration[5.2]
  def change
    add_column :track_group_habits, :health_difference, :integer
    add_column :track_group_habits, :experience_difference, :integer
  end
end
