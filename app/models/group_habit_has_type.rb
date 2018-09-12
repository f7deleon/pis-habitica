# frozen_string_literal: true

class GroupHabitHasType < ApplicationRecord
  belongs_to :group_habit, foreign_key: :habit_id
  belongs_to :type
end
