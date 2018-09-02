class HabitsController < ApplicationController
  before_action :set_habit, only: [:show, :update, :destroy]

  # GET /habits
  def index
    @habits = Habit.all

    render json: @habits
  end

  # GET /habits/1
  def show
    render json: @habit
  end

  # POST /habits
  def create
    @habit = Habit.new(habit_params)
    habit_params = JSON.parse(params[:habit])
    us_id = habit_params[:user_id]

    #FIXME: Preguntar Users.exists?(id)
    @user = Users.find(us_id)

    @user_habit = UserHabit.new(habit_id: @habit.id, user_id: @user.id)
    @user.user_habits << @user_habit
    @habit.user_habits << @user_habit
    
    if @habit.save
      render json: @habit, status: :created, location: @habit
    else
      render json: @habit.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /habits/1
  def update
    if @habit.update(habit_params)
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
    # Use callbacks to share common setup or constraints between actions.
    def set_habit
      @habit = Habit.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def habit_params
      params.require(:habit).permit(:name, :frecuency, :difficulty, :hasEnd, :privacy, :endDate)
    end
end
