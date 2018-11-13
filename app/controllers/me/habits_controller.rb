# frozen_string_literal: true

class Me::HabitsController < Me::ApplicationController
  require 'will_paginate/array'

  # GET /me/habits
  def index
    habits = current_user.individual_habits
    habits = paginate habits.where(active: true).order('name ASC'), per_page: params['per_page'].to_i
    render json: IndividualHabitInfoSerializer.new(habits, params: { time_zone: params['time_zone'] }).serialized_json
  end
end
