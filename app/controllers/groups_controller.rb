# frozen_string_literal: true

require 'will_paginate/array'

class GroupsController < ApplicationController
  before_action :set_group, only: %i[habits members show]
  before_action :create_group, only: %i[create]
  before_action :update_members_requirements, only: %i[update_members]

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

  # GET /groups/:id
  def show
    memberships = @group.memberships.ordered_by_score_and_name
    data = []
    memberships.each_with_index do |membership, i|
      data[i] = { id: membership.user_id, score: membership.score }
    end
    parameters = { current_user: current_user, time_zone: params['time_zone'] }
    render json: GroupSerializer.new(@group, params: parameters).serialized_json, status: :ok
  end

  # GET /groups/:id/habits
  def habits
    habits = @group.group_habits.order('name ASC').select(&:active)
    options = {}
    options[:include] = %i[types]
    options[:params] = { id: current_user.id }
    render json: GroupHabitSerializer.new(habits, options).serialized_json, status: :ok
  end

  # GET /groups/:id/members
  def members
    members = paginate @group.memberships.ordered_by_score_and_name.map(&:user), per_page: params[:per_page]
    options = {}
    options[:params] = { current_user: current_user, group_id: @group.id }
    render json: MemberInfoSerializer.new(members, options).serialized_json, status: :ok
  end

  # POST /groups
  def create
    params[:data][:relationships][:members][:data].each do |member|
      unless User.exists?(member[:id])
        raise Error::CustomError.new(I18n.t(:bad_request), '404', I18n.t('errors.messages.member_not_exist'))
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
    options = {}
    options[:params] = { current_user: current_user }
    render json: GroupSerializer.new(group, options).serialized_json, status: :ok
  end

  def update_members
    @group.update_members(params[:data], current_user)
    options = {}
    options[:params] = { current_user: current_user }
    render json: GroupSerializer.new(@group, options).serialized_json, status: :created
  end

  private

  def set_group
    raise Error::CustomError.new(I18n.t('not_found'), '404', I18n.t('errors.messages.group_not_found')) unless
    (@group = Group.find_by(id: params[:id]))

    raise Error::CustomError.new(I18n.t(:unauthorized), '403', I18n.t('errors.messages.group_is_private')) if
     !@group.memberships.find_by(user_id: current_user.id) && @group.privacy?
  end

  # Only allow a trusted parameter "white list" through.
  def group_params
    params.require(:group).permit(:name, :description)
  end

  def update_members_requirements
    raise Error::CustomError.new(I18n.t('not_found'), '404', I18n.t('errors.messages.group_not_found')) unless
    (@group = current_user.groups.find_by(id: params[:id]))

    unless @group.memberships.find_by(user_id: current_user.id).admin?
      raise Error::CustomError.new(I18n.t(:forbidden), '403', I18n.t('errors.messages.not_admin'))
    end

    params.require(:data)

    raise Error::CustomError.new(I18n.t(:bad_request), '400', I18n.t('errors.messages.no_users_to_add')) if
      params[:data][0].blank?
  end

  def create_group
    params.require(:data).require(:attributes).require(%i[name privacy])
  end
end
