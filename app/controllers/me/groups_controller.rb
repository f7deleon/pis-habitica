# frozen_string_literal: true

class Me::GroupsController < Me::ApplicationController
  before_action :set_group, only: %i[add_habits show habits habit]
  before_action :create_habit, only: %i[add_habits]
  before_action :create_group, only: %i[create]

  # GET /me/groups
  def index
    groups = current_user.groups
    render json: GroupSerializer.new(groups).serialized_json
  end

  # GET /me/groups/gid
  def show
    options = {}
    options[:include] = %i[group_habits members admin]
    render json: GroupSerializer.new(@group, options).serialized_json, status: :ok
  end

  # POST /me/groups
  def create
    params[:data][:relationships][:members][:data].each do |member|
      unless User.exists?(member[:id])
        raise Error::CustomError.new(I18n.t(:bad_request), '404', I18n.t('errors.messages.member_not_exist'))
      end
      unless current_user.friends.exists?(member[:id])
        raise Error::CustomError.new(I18n.t(:bad_request), '404', I18n.t('errors.messages.member_not_friend'))
      end
    end
    params_attributte = params[:data][:attributes]
    group = Group.create(name: params_attributte[:name],
                         description: params_attributte[:description],
                         privacy: params_attributte[:privacy])
    Membership.create(user_id: current_user.id, group_id: group.id, admin: true)
    params[:data][:relationships][:members][:data].each do |member|
      Membership.create(user_id: member[:id], group_id: group.id, admin: false)
    end
    render json: GroupSerializer.new(group).serialized_json, status: :ok
  end

  # POST /me/groups/id/habits
  def add_habits
    unless @group.memberships.find_by!(user_id: current_user.id).admin?
      raise Error::CustomError.new(I18n.t(:unauthorized), '403', I18n.t('errors.messages.not_admin'))
    end

    habit_params = params[:data][:attributes]
    type_ids_params = params[:data][:relationships][:types]

    # At least one type
    if type_ids_params[0].blank?
      raise Error::CustomError.new(I18n.t('bad_request'), :bad_request, I18n.t('errors.messages.typeless_habit'))
    end

    type_ids = []
    type_ids_params.each { |type| type_ids << type[:data][:id] }

    # Type does not exist
    individual_types = Type.find(type_ids)

    habit = GroupHabit.new(
      group_id: params[:id],
      name: habit_params[:name],
      description: habit_params[:description],
      difficulty: habit_params[:difficulty],
      frequency: habit_params[:frequency],
      negative: habit_params[:negative],
      privacy: 1
    )

    habit.save!

    individual_types.each do |type|
      GroupHabitHasType.create(habit_id: habit.id, type_id: type.id)
    end
    render json: GroupHabitSerializer.new(habit).serialized_json, status: :created
  end

  # GET /me/groups/id/habits
  def habits
    habits = @group.group_habits
    render json: GroupHabitSerializer.new(habits).serialized_json, status: :ok
  end

  # GET /me/groups/id/habits/id
  def habit
    unless @group.memberships.find_by(user_id: current_user.id)
      raise Error::CustomError.new(I18n.t(:unauthorized), '403', I18n.t('errors.messages.not_belong'))
    end

    habit = @group.group_habits.find(params[:habit])
    render json: GroupHabitSerializer.new(habit).serialized_json, status: :ok
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    raise Error::CustomError.new(I18n.t('not_found'), '404', I18n.t('errors.messages.group_not_found')) unless
    (@group = current_user.groups.find_by!(id: params[:id]))
  end

  def create_habit
    params.require(:data).require(:attributes).require(%i[name frequency difficulty])
    # Esto no controla que types sea un array ni que sea no vacio, esa verificacion se hace internamente en creates.
    params.require(:data).require(:relationships).require(:types)
  end

  # Only allow a trusted parameter 'white list' through.
  def habit_params
    params.require(:habit).permit(:group_id, :name, :frequency, :difficulty)
  end

  def create_group
    params.require(:data).require(:attributes).require(%i[name privacy])
  end
end
