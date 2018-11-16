# frozen_string_literal: true

class Me::GroupsController < Me::ApplicationController
  before_action :set_group, only: %i[destroy]

  # GET /me/groups
  def index
    options = {}
    options[:params] = { current_user: current_user }
    groups = paginate current_user.groups.order('name ASC'), per_page: params['per_page'].to_i
    render json: GroupInfoSerializer.new(groups, options).serialized_json
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
end
