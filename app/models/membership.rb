# frozen_string_literal: true

class Membership < ApplicationRecord
  before_validation :set_default, on: :create

  belongs_to :user, foreign_key: :user_id
  belongs_to :group, foreign_key: :group_id # sender
  validates :admin, inclusion: [true, false]

  def set_default
    self.score ||= 0
  end

  def modify_score(difference)
    self.score += difference
    update_attributes(score: score)
  end

  scope :ordered_by_score_and_name, -> { joins(:user).order('score DESC, nickname ASC') }
end
