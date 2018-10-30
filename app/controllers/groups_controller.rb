# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :set_user, only: %i[index show indexupdate destroy]

  # GET /groups
  def index
    groups = @user.groups
    options = {}
    options[:include] = %i[group_habits members admin]
    render json: GroupSerializer.new(groups).serialized_json
  end

  # GET /user/:user_id/groups/:id
  def show
    raise Error::CustomError.new(I18n.t('not_found'), '404', I18n.t('errors.messages.group_not_found')) unless
      (@group = @user.groups.find_by(id: params[:id]))

    raise Error::CustomError.new(I18n.t('not_found'), '404', I18n.t('errors.messages.group_is_private')) unless
    !@group.privacy || current_user.groups.find_by(id: params[:id])

    options = {}
    options[:include] = %i[group_habits members admin]
    render json: GroupSerializer.new(@group, options).serialized_json, status: :ok
  end

  # POST /groups
  def create
    @group = Group.new(group_params)

    if @group.save
      render json: @group, status: :created, location: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      render json: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:user_id])
  end

  # Only allow a trusted parameter "white list" through.
  def group_params
    params.require(:group).permit(:name, :description)
  end
end
