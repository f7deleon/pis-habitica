# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :set_group, only: %i[habits habit]
  before_action :set_user, only: %i[index show habits habit]

  # GET /users/:user_id/groups
  def index
    groups = @user.groups.find_by(privacy: false)
    options = {}
    options[:include] = %i[group_habits members admin]
    render json: GroupInfoSerializer.new(groups).serialized_json
  end

  # GET /users/:user_id/groups/:id
  def show
    raise Error::CustomError.new(I18n.t('not_found'), '404', I18n.t('errors.messages.group_not_found')) unless
      (@group = @user.groups.find_by(id: params[:id]))

    raise Error::CustomError.new(I18n.t(:unauthorized), '403', I18n.t('errors.messages.group_is_private')) unless
      !@group.privacy || current_user.groups.find_by(id: params[:id])

    options = {}
    options[:include] = %i[group_habits members admin]
    render json: GroupSerializer.new(@group, options).serialized_json, status: :ok
  end

  # GET /users/:user_id/groups/:id/habits
  def habits
    unless @group.memberships.find_by(user_id: current_user.id) || !@group.privacy?
      raise Error::CustomError.new(I18n.t(:unauthorized), '403', I18n.t('errors.messages.not_belong'))
    end

    habits = @group.group_habits
    options = {}
    options[:include] = %i[types]
    options[:params] = { id: @user.id }
    render json: GroupHabitSerializer.new(habits, options).serialized_json, status: :ok
  end

  # GET /users/:user_id/groups/:id/habits/:habit
  def habit
    unless @group.memberships.find_by(user_id: current_user.id) || !@group.privacy?
      raise Error::CustomError.new(I18n.t(:unauthorized), '403', I18n.t('errors.messages.not_belong'))
    end

    habit = @group.group_habits.find(params[:habit])
    options = {}
    options[:include] = %i[types]
    options[:params] = { id: @user.id }
    render json: GroupHabitSerializer.new(habit, options).serialized_json, status: :ok
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:user_id])
  end

  def set_group
    @group = Group.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def group_params
    params.require(:group).permit(:name, :description)
  end
end
