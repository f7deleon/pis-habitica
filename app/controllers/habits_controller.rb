# frozen_string_literal: true

class HabitsController < ApplicationController
  before_action :set_habit, only: %i[show update destroy]
  before_action :create_habit, only: %i[create]
  # GET /habits
  def index
    @habits = IndividualHabit.all
    render json: @habits
  end

  # GET /habits/1
  def show
    render json: @habit
  end

  # POST /habits
  def create
    habit_params = params[:data][:attributes]
    user_id = params[:token]
    type_ids_params = params[:data][:relationships][:types]
    type_ids = []
    type_ids_params.each { |type| type_ids << type[:data][:id] }
    unless (user = User.find_by(id: user_id))
      # User does not exist
      render json: {
        'errors': [
          {
            'status': 403,
            'title': 'Forbidden',
            'details': 'Invalid token'
          }
        ]
      }, status: :forbidden
      return
    end
    unless type_ids.all? { |type| Type.exists?(type) }
      # Type does not exist
      render json: {
        'errors': [
          {
            'status': 404,
            'title': 'Type not found',
            'details': 'Type does not exist'
          }
        ]
      }, status: :not_found
      return
    end
    individual_types = Type.find(type_ids)

    habit = IndividualHabit.new(
      user_id: user.id,
      name: habit_params[:name],
      description: habit_params[:description],
      difficulty: habit_params[:difficulty],
      privacy: habit_params[:privacy],
      frequency: habit_params[:frequency]
    )
    if habit.save
      user.individual_habits << habit
      individual_types.each do |type|
        individual_habit_has_type = IndividualHabitHasType.create(individual_habit_id: habit.id, type_id: type.id)
        habit.individual_habit_has_types << individual_habit_has_type
        type.individual_habit_has_types << individual_habit_has_type
      end
      render json: habit, status: :created
    else
      render json: {
        'errors': [
          {}
        ]
      }
    end
  end

  # POST habits/fulfill
  def fulfill_habit
    habit_params = params[:data][:relationships][0][:"track-individual-habits"][:data][:attributes]
    user_id = params[:token]
    habit_id = params[:data][:id]
    unless (user = User.find_by(id: user_id))
      # User does not exist
      render json: {
        'errors': [
          {
            'status': 403,
            'title': 'Forbidden',
            'details': 'Invalid token'
          }
        ]
      }, status: :forbidden
      return
    end
    unless user.individual_habits.exists?(habit_id)
      # User does not have this habit
      render json: {
        'errors': [
          {
            'status': 404,
            'title': 'Not found',
            'details': 'User does not have this habit'
          }
        ]
      }, status: :not_found
      return
    end
    habit = IndividualHabit.find(habit_id)
    unless check_iso8601(habit_params[:date])
      # date is not in ISO 8601
      render json: {
        'errors': [
          {
            'status': 400,
            'title': 'Bad request',
            'details': 'Date is not in ISO 8601'
          }
        ]
      }, status: :bad_request
      return
    end

    date_passed = Time.zone.parse(habit_params[:date])
    unless habit.frequency == 1 || habit_has_been_tracked_today(habit, date_passed).nil?
      # Habit frequency is daily and it has been fulfilled today
      render json: {
        'errors': [
          {
            'status': 409,
            'title': 'Conflict',
            'details': 'Habit frequency is daily and it has been fulfilled today'
          }
        ]
      }, status: :conflict
      return
    end
    # If frequency = default || has not been fullfilled
    track_individual_habit = TrackIndividualHabit.new(individual_habit_id: habit.id, date: date_passed)
    if track_individual_habit.save
      habit.track_individual_habits << track_individual_habit
      render json: habit, status: :created
      return
    end

    render json: {
      'errors': [
        {}
      ]
    }
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

  private

  def habit_has_been_tracked_today(habit, date)
    habit.track_individual_habits.created_between(
      date.beginning_of_day,
      date.end_of_day
    )
  end

  def check_iso8601(date)
    Time.iso8601(date)
  rescue ArgumentError
    nil
  end

  def create_habit
    params.require(:data).require(:attributes).require(%i[name description frequency difficulty privacy])
    params.require(:data).require(:relationships).require(:types)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_habit
    @habit = IndividualHabit.find(params[:id])
  end

  # Only allow a trusted parameter 'white list' through.
  def habit_params
    params.require(:habit).permit(:user_id, :name, :frequency, :difficulty, :privacy)
  end
end
