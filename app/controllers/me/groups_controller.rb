# frozen_string_literal: true

class Me::GroupsController < Me::ApplicationController
  before_action :set_group, only: %i[add_habits show habits habit update_members destroy]
  before_action :create_group, only: %i[create]
  before_action :update_members_requirements, only: %i[update_members]

  # GET /me/groups
  def index
    groups = paginate current_user.groups, per_page: params['per_page'].to_i
    render json: GroupInfoSerializer.new(groups).serialized_json
  end

  # GET /me/groups/gid
  def show
    options = %i[group_habits members]

    memberships = @group.memberships.ordered_by_score_and_name
    data = []
    memberships.each_with_index do |membership, i|
      data[i] = { id: membership.user_id, score: membership.score }
    end
    parameters = { id: current_user.id, time_zone: params['time_zone'] }
    render json: GroupAndScoresSerializer.json(data, @group, options, parameters), status: :ok
  end

  # POST /me/groups
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
    options[:include] = %i[members admin]
    options[:params] = { id: current_user.id }
    render json: GroupSerializer.new(group, options).serialized_json, status: :ok
  end

  # GET /me/groups/id/habits
  def habits
    habits = @group.group_habits
    render json: GroupHabitInfoSerializer.new(habits, params: { id: current_user.id }).serialized_json, status: :ok
  end

  def update_members
    @group.update_members(params[:data], current_user)
    render json: GroupSerializer.new(@group).serialized_json, status: :created
  end

  def destroy
    @group.delete if @group.erase_member(current_user.id)
    render status: 204
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    raise Error::CustomError.new(I18n.t('not_found'), '404', I18n.t('errors.messages.group_not_found')) unless
    (@group = current_user.groups.find_by!(id: params[:id]))
  end

  def update_members_requirements
    unless @group.memberships.find_by(user_id: current_user.id).admin?
      raise Error::CustomError.new(I18n.t(:forbidden), '403', I18n.t('errors.messages.not_admin'))
    end

    params.require(:data)

    raise Error::CustomError.new(I18n.t(:bad_request), '400', I18n.t('errors.messages.no_users_to_add')) if
      params[:data][0].blank?
  end

  # Only allow a trusted parameter 'white list' through.
  def habit_params
    params.require(:habit).permit(:group_id, :name, :frequency, :difficulty)
  end

  def create_group
    params.require(:data).require(:attributes).require(%i[name privacy])
  end
end
