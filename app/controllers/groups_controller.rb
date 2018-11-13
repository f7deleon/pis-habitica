# frozen_string_literal: true

require 'will_paginate/array'

class GroupsController < ApplicationController
  before_action :set_group, only: %i[habits habit]
  before_action :set_user, only: %i[index show habits habit]

  # GET /users/:user_id/groups
  def index
    options = {}
    options[:params] = { current_user: current_user }
    groups = paginate @user.groups.where(privacy: false).order('name ASC'), per_page: params[:per_page].to_i
    render json: GroupInfoSerializer.new(groups, options).serialized_json
  end

  # GET /groups
  def find_group
    my_groups = current_user.groups.select do |item|
      item.name.downcase.include?(params[:filter].downcase)
    end
    public_groups = Group.all.select do |item|
      item.name.downcase.include?(params[:filter].downcase) && !item.privacy && !item.member_in_group(current_user.id)
    end
    my_groups.sort_by! { |group| group[:name].downcase } unless my_groups.length.zero?
    public_groups.sort_by! { |group| group[:name].downcase } unless public_groups.length.zero?
    groups = paginate my_groups.concat(public_groups), per_page: params['per_page'].to_i
    options = {}
    options[:params] = { current_user: current_user }
    render json: GroupInfoSerializer.new(groups, options).serialized_json, status: :ok
  end

  # GET /users/:user_id/groups/:id
  def show
    raise Error::CustomError.new(I18n.t('not_found'), '404', I18n.t('errors.messages.group_not_found')) unless
      (@group = Group.find_by(id: params[:id]))

    raise Error::CustomError.new(I18n.t(:unauthorized), '403', I18n.t('errors.messages.group_is_private')) unless
      !@group.privacy || current_user.groups.find_by(id: params[:id])

    options = %i[group_habits members]

    memberships = @group.memberships.ordered_by_score_and_name
    data = []
    memberships.each_with_index do |membership, i|
      data[i] = { id: membership.user_id, score: membership.score }
    end
    parameters = { id: current_user.id, time_zone: params['time_zone'] }
    render json: GroupAndScoresSerializer.json(data, @group, options, parameters), status: :ok
  end

  # GET /users/:user_id/groups/:id/habits
  def habits
    unless @group.memberships.find_by(user_id: current_user.id) || !@group.privacy?
      raise Error::CustomError.new(I18n.t(:unauthorized), '403', I18n.t('errors.messages.not_belong'))
    end

    habits = @group.group_habits.order('name ASC').select(&:active)
    options = {}
    options[:include] = %i[types]
    options[:params] = { id: @user.id }
    render json: GroupHabitSerializer.new(habits, options).serialized_json, status: :ok
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
