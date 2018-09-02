# frozen_string_literal: true

class CreateIndividualTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :individual_types, primary_key: %i[type_id user_id] do |t|
      t.belongs_to :type, index: true, foreign_key: true
      t.belongs_to :user, index: true, foreign_key: true
    end
  end
end
