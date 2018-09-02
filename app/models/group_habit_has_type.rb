# frozen_string_literal: true

class GroupHabitHasType < ApplicationRecord
  belongs_to :group_habit
  belongs_to :type

  self.primary_key = :group_habit_id, :type_id
end
