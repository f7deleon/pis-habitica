# frozen_string_literal: true

class HabitsController < ApplicationController
  require 'will_paginate/array'
  before_action :set_user_and_habit, only: %i[index show]

  # GET /user/:user_id/habits

  def index
    habits = paginate @user.get_habits_from_user(current_user), per_page: params[:per_page].to_i

    render json: IndividualHabitInfoSerializer.new(habits).serialized_json
  end

  # GET /user/:user_id/habits/:id

  def show
    habit = @user.individual_habits.find(params[:id])

    raise Error::CustomError.new(I18n.t('unauthorized'), :unauthorized, I18n.t('errors.messages.habit_is_private')) if
    habit.privacy == 3

    raise Error::CustomError.new(I18n.t('unauthorized'), :unauthorized, I18n.t('errors.messages.habit_is_protected')) if
    habit.privacy == 2 && @user.friends.find_by(id: current_user.id).nil?

    time_now = Time.zone.now
    max, successive, percent, calendar, months =
      habit.frequency == 1 ? habit.get_stat_not_daily(time_now) : habit.get_stat_daily(time_now)
    data = { "max": max,
             "successive": successive,
             "percent": percent,
             "calendar": calendar,
             "months": months }
    render json: StatsSerializer.json(data, habit), status: :ok
  end

  def set_user_and_habit
    @user = User.find(params[:user_id])
  end
end
