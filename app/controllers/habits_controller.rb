# frozen_string_literal: true

class HabitsController < ApplicationController
  before_action :set_habit, only: %i[update destroy]

  # GET /habits
  def index
    @habits = IndividualHabit.all

    render json: @habits
  end

  # PATCH/PUT /habits/1
  def update
    if @habit.update(params)
      render json: @habit
    else
      render json: @habit.errors, status: :unprocessable_entity
    end
  end

  # DELETE /habits/1
  def destroy
    @habit.destroy
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_habit
    @habit = IndividualHabit.find(params[:id])
  end
end
