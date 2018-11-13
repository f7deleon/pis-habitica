# frozen_string_literal: true

class HabitsController < ApplicationController
  require 'will_paginate/array'

  before_action :create_habit, only: %i[create]
  before_action :update_habit, only: %i[update]
  before_action :fulfill_habit, only: %i[fulfill]
  before_action :check_alive, only: %i[undo_habit fulfill]
  before_action :set_habit, only: %i[update destroy fulfill show undo_habit]
  before_action :check_user, only: %i[update fulfill undo_habit]
  before_action :check_privacy, only: %i[show]
  before_action :check_admin, only: %i[update destroy]

  # GET /me/habits
  def index
    habits = current_user.individual_habits
    habits = paginate habits.where(active: true).order('name ASC'), per_page: params['per_page'].to_i
    render json: IndividualHabitInfoSerializer.new(habits, params: { time_zone: params['time_zone'] }).serialized_json
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
    raise ActiveRecord::RecordNotFound unless (types = Type.find(type_ids))

    if params[:data][:type].eql?('group_habit')
      group = Group.find_by!(id: params[:data][:relationships][:group][:id])
      unless (membership = group.memberships.find_by(user_id: current_user.id))
        message = I18n.t('errors.messages.not_admin_of_group')
        raise Error::CustomError.new(I18n.t('forbidden'), :forbidden, message)
      end

      message = I18n.t('errors.messages.not_admin_of_group')
      raise Error::CustomError.new(I18n.t('forbidden'), :forbidden, message) unless membership.admin

      habit = GroupHabit.new(
        group_id: group.id,
        name: habit_params[:name],
        description: habit_params[:description],
        difficulty: habit_params[:difficulty],
        frequency: habit_params[:frequency],
        negative: habit_params[:negative],
        privacy: 1
      )
      habit.save!
      types.each do |type|
        GroupHabitHasType.create(habit_id: habit.id, type_id: type.id)
      end
      render json: GroupHabitSerializer.new(habit, params: { id: current_user.id }).serialized_json, status: :created
    else # Individual
      habit = IndividualHabit.new(
        user_id: current_user.id,
        name: habit_params[:name],
        description: habit_params[:description],
        difficulty: habit_params[:difficulty],
        privacy: habit_params[:privacy],
        frequency: habit_params[:frequency],
        negative: habit_params[:negative]
      )
      habit.save!
      types.each do |type|
        IndividualHabitHasType.create(habit_id: habit.id, type_id: type.id)
      end
      render json: IndividualHabitSerializer.new(habit).serialized_json, status: :created
    end
  end

  # POST /habits/Hid/fulfill
  def fulfill
    previous_level = current_user.level
    track_habit = if @habit.type.eql?('GroupHabit')
                    @habit.fulfill(@date_passed, current_user)
                  else
                    @habit.fulfill(@date_passed)
                  end
    user = User.find_by_id(current_user.id)
    if previous_level < user.level
      render json: LevelUpSerializer.new(
        user,
        params: { habit: @habit.id }
      ).serialized_json, status: :created
    else
      render json: TrackHabitSerializer.new(
        track_habit, params: { current_user: user }
      ), status: :created
    end
  end

  # PATCH/PUT /habits/id
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

  # GET /habits/id
  def show
    if @habit.type.eql?('GroupHabit')
      options = {}
      options[:include] = %i[types]
      options[:params] = { id: current_user.id }
      render json: GroupHabitSerializer.new(@habit, options).serialized_json, status: :ok
    else # Individual
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
  end

  def undo_habit
    track_to_delete = if @habit.type.eql?('GroupHabit')
                        @habit.track_group_habits.find_all do |track|
                          track.user_id.eql?(current_user.id)
                        end.max_by(&:date)
                      else # Individual
                        @habit.track_individual_habits.order(:date).last
                      end
    unless track_to_delete && track_to_delete.date.to_date == Time.zone.now.to_date
      raise Error::CustomError.new(I18n.t('not_found'), :not_found, I18n.t('errors.messages.habit_not_fulfilled'))
    end

    if @habit.type.eql?('GroupHabit')
      render json: @habit.undo_track(track_to_delete, current_user), status: :accepted # 202
    else
      render json: @habit.undo_track(track_to_delete), status: :accepted # 202
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_habit
    @habit = Habit.find_by!(id: params[:id], active: true)
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
    params.require(:data).require(:type)
    # Esto no controla que types sea un array ni que sea no vacio, esa verificacion se hace internamente en creates.
    params.require(:data).require(:relationships).require(:types)
    params.require(:data).require(:attributes).require(%i[name frequency difficulty])
    if params[:data][:type].eql?('group_habit')
      params.require(:data).require(:relationships).require(:group)
    else
      params.require(:data).require(:attributes).require(:privacy)
    end
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

  def check_admin
    message = I18n.t('errors.messages.not_admin_of_group')
    raise Error::CustomError.new(I18n.t('forbidden'), :forbidden, message) unless
      !@habit.type.eql?('GroupHabit') || @habit.group.memberships.find_by!(user_id: current_user.id).admin
  end

  def check_user
    if @habit.type.eql?('GroupHabit')
      message = I18n.t('errors.messages.group_habit_is_not_from_user')
      raise Error::CustomError.new(I18n.t('forbidden'), '403', message) unless
        current_user.groups.find_by(id: @habit.group_id)
    else # Individual
      message = I18n.t('errors.messages.habit_is_not_from_user')
      raise Error::CustomError.new(I18n.t('forbidden'), '403', message) unless current_user.id.equal?(@habit.user_id)
    end
  end

  def check_privacy
    message = I18n.t('errors.messages.not_permission_to_show')
    raise Error::CustomError.new(I18n.t('forbidden'), '403', message) unless @habit.can_be_seen_by(current_user)
  end

  # Only allow a trusted parameter 'white list' through.
  def habit_params
    if params[:data][:type].eql?('group_habit')
      params.require(:habit).permit(:user_id, :name, :frequency, :difficulty)
    else
      params.require(:habit).permit(:group_id, :name, :frequency, :difficulty, :privacy)
    end
  end
end
