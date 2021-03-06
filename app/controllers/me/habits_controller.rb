# frozen_string_literal: true

class Me::HabitsController < Me::ApplicationController
  before_action :create_habit, only: %i[create]
  before_action :update_habit, only: %i[update]
  before_action :fulfill_habit, only: %i[fulfill]
  before_action :check_alive, only: %i[undo_habit]
  before_action :set_habit, only: %i[update destroy fulfill show stat_habit undo_habit]

  # GET /me/habits
  def index
    habits = current_user.individual_habits
    habits = habits.order('name ASC').select(&:active)
    render json: IndividualHabitInfoSerializer.new(habits).serialized_json
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
      negative: habit_params[:negative]
    )

    raise ActiveRecord::RecordInvalid unless habit.save!

    current_user.individual_habits << habit
    individual_types.each do |type|
      individual_habit_has_type = IndividualHabitHasType.create(habit_id: habit.id, type_id: type.id)
      habit.individual_habit_has_types << individual_habit_has_type
    end
    render json: IndividualHabitSerializer.new(habit).serialized_json, status: :created
  end

  # POST /me/habits/Hid/fulfill & /me/groups/Gid/habits/Hid/fulfill
  def fulfill
    previous_level = current_user.level
    track_habit = if @habit.type.eql?('GroupHabit')
                    @habit.fulfill(@date_passed, current_user)
                  else
                    @habit.fulfill(@date_passed)
                  end
    if previous_level < current_user.level
      render json: LevelUpSerializer.new(
        current_user,
        params: { habit: @habit.id }
      ).serialized_json, status: :created
    else
      render json: TrackHabitSerializer.new(
        track_habit, params: { current_user: current_user }
      ), status: :created
    end
  end

  # PATCH/PUT /me/habits/id
  def update
    params_update = params[:data][:attributes]
    if params_update[:active].to_i.zero?
      # Borrado
      if @habit.type.eql?('GroupHabit')
        unless @habit.group.memberships.find_by!(user_id: current_user.id).admin
          raise Error::CustomError.new(I18n.t('forbidden'), :forbidden, I18n.t('errors.messages.not_admin_to_delete'))
        end
      end

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
    max, successive, percent, calendar, months =
      @habit.frequency == 1 ? @habit.get_stat_not_daily(time_now) : @habit.get_stat_daily(time_now)
    data = { 'max': max,
             'successive': successive,
             'percent': percent,
             'calendar': calendar,
             'months': months }
    render json: StatsSerializer.json(data, @habit), status: :ok
  end

  def undo_habit
    time_now = Time.zone.now
    track_to_delete = if @habit.type.eql?('GroupHabit')
                        @habit.track_group_habits.find_all do |track|
                          track.user_id.eql?(current_user.id)
                        end.max_by(&:date)
                      else # Individual
                        @habit.track_individual_habits.order(:date).last
                      end
    unless track_to_delete && track_to_delete.date.to_date == time_now.to_date
      raise Error::CustomError.new(I18n.t('not_found'), :not_found, I18n.t('errors.messages.habit_not_fulfilled'))
    end

    # Solo se le resta la vida si no habia subido de nivel con este track.
    health_difference = current_user.modify_health(-track_to_delete.health_difference) if current_user.experience >= 0
    render json: UndoHabitSerializer.new(
      @habit,
      params: {
        health_difference: health_difference || 0,
        # experience_difference = 0 Si el habito es negativo
        experience_difference: current_user.modify_experience(-track_to_delete.experience_difference),
        current_user: current_user
      }
    ).serialized_json, status: :accepted # 202
    track_to_delete.delete
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_habit
    # Se busca solo en los habitos individuales del usuario logueado.
    @habit = if params[:group_id]
               current_user.groups.find_by!(id: params[:group_id]).group_habits.find_by!(id: params[:id], active: true)
             else
               current_user.individual_habits.find_by!(id: params[:id], active: true)
             end
  end

  def check_iso8601(date)
    Time.iso8601(date)
  rescue ArgumentError
    nil
  end

  def update_habit
    params.require(:data).require(:attributes)
  end

  def check_alive
    message = I18n.t('errors.messages.no_character_created')
    raise Error::CustomError.new(I18n.t('not_found'), '404', message) if current_user.dead?
  end

  def create_habit
    params.require(:data).require(:attributes).require(%i[name frequency difficulty privacy])
    # Esto no controla que types sea un array ni que sea no vacio, esa verificacion se hace internamente en creates.
    params.require(:data).require(:relationships).require(:types)
  end

  def fulfill_habit
    params.require(:data).require(:attributes).require(:date)
    date_params = params[:data][:attributes][:date]
    # date is not in ISO 8601
    unless check_iso8601(date_params)
      raise Error::CustomError.new(I18n.t('bad_request'), :bad_request, I18n.t('errors.messages.date_formatting'))
    end

    @date_passed = Time.zone.parse(date_params)
    message = I18n.t('errors.messages.no_character_created')
    raise Error::CustomError.new(I18n.t('not_found'), '404', message) if current_user.dead?
  end

  # Only allow a trusted parameter 'white list' through.
  def habit_params
    params.require(:habit).permit(:user_id, :name, :frequency, :difficulty, :privacy)
  end
end
