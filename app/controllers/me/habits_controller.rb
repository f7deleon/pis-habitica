# frozen_string_literal: true

class Me::HabitsController < Me::ApplicationController
  before_action :create_habit, only: %i[create]
  before_action :update_habit, only: %i[update]
  before_action :fulfill_habit, only: %i[fulfill]
  before_action :set_habit, only: %i[update destroy fulfill show stat_habit]

  # GET /me/habits
  def index
    habits = current_user.individual_habits
    habits = habits.select(&:active)
    render json: IndividualHabitSerializer.new(habits).serialized_json
  end

  # POST /me/habits
  def create
    habit_params = params[:data][:attributes]
    type_ids_params = params[:data][:relationships][:types]

    # At least one type
    if type_ids_params[0].blank?
      raise Error::CustomError.new(I18n.t('bad_request'), :bad_request, I18n.t('errors.messages.typeless_habit'))
    end

    type_ids = []
    type_ids_params.each { |type| type_ids << type[:data][:id] }

    # Type does not exist
    raise ActiveRecord::RecordNotFound unless (individual_types = Type.find(type_ids))

    habit = IndividualHabit.new(
      user_id: current_user.id,
      name: habit_params[:name],
      description: habit_params[:description],
      difficulty: habit_params[:difficulty],
      privacy: habit_params[:privacy],
      frequency: habit_params[:frequency],
      active: true
    )

    raise ActiveRecord::RecordInvalid unless habit.save!

    current_user.individual_habits << habit
    individual_types.each do |type|
      individual_habit_has_type = IndividualHabitHasType.create(habit_id: habit.id, type_id: type.id)
      habit.individual_habit_has_types << individual_habit_has_type
    end
    render json: IndividualHabitSerializer.new(habit).serialized_json, status: :created
  end

  # POST /me/habits/fulfill
  def fulfill
    date_params = params[:data][:attributes][:date]

    # date is not in ISO 8601
    unless check_iso8601(date_params)
      raise Error::CustomError.new(I18n.t('bad_request'), :bad_request, I18n.t('errors.messages.date_formatting'))
    end

    date_passed = Time.zone.parse(date_params)

    # Habit frequency is daily and it has been fulfilled today
    if @habit.frequency == 2 && !habit_has_been_tracked_today(@habit, date_passed).empty?
      raise Error::CustomError.new(I18n.t('conflict'), :conflict, I18n.t('errors.messages.daily_fulfilled'))
    end

    # If frequency = default || has not been fullfilled
    track_individual_habit = TrackIndividualHabit.new(habit_id: @habit.id, date: date_passed)
    raise ActiveRecord::RecordInvalid unless track_individual_habit.save!

    @habit.track_individual_habits << track_individual_habit
    render json: IndividualHabitSerializer.new(@habit).serialized_json, status: :created
  end

  # PATCH/PUT /me/habits/id
  def update
    params_update = params[:data][:attributes]
    if params_update[:active].to_i.zero?
      # Borrado
      @habit.active = 0
      @habit.save
      render json: {}, status: :no_content
    else
      # Modificar
      raise ActiveRecord::RecordInvalid unless @habit.update(params_update)

      render json: IndividualHabitSerializer.new(@habit).serialized_json, status: :ok
    end
  end

  # GET /me/habits/id
  def show
    # Los checkeos que esto hacia se hace en set_habit
    time_now = Time.zone.now
    max, successive = @habit.get_sucesive_max(time_now)
    porcent_months, porcent = @habit.get_porcent_month(time_now)
    render json: StatsSerializer.json(@habit, max, successive, porcent, porcent_months), status: :ok
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_habit
    # Se busca solo en los habitos individuales del usuario logueado.
    raise ActiveRecord::RecordNotFound unless (@habit =
                                                 current_user.individual_habits.find_by!(id: params[:id], active: true))
  end

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

  def update_habit
    params.require(:data).require(:attributes)
  end

  def create_habit
    params.require(:data).require(:attributes).require(%i[name frequency difficulty privacy])
    # Esto no controla que types sea un array ni que sea no vacio, esa verificacion se hace internamente en creates.
    params.require(:data).require(:relationships).require(:types)
  end

  def fulfill_habit
    params.require(:data).require(:attributes).require(:date)
  end

  # Only allow a trusted parameter 'white list' through.
  def habit_params
    params.require(:habit).permit(:user_id, :name, :frequency, :difficulty, :privacy)
  end
end
