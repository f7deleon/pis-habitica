# frozen_string_literal: true

class HabitsController < ApplicationController
  before_action :authenticate_user
  before_action :set_habit, only: %i[update destroy]

  # GET /habits
  def index
    @habits = IndividualHabit.all

    render json: @habits
  end

  # DELETE habits/id
  def destroy
    @habit.destroy
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_habit
    @habit = IndividualHabit.find(params[:id])
  end
end
