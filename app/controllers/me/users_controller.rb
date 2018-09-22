# frozen_string_literal: true

class Me::UsersController < Me::ApplicationController
  def home
    # There is no home if user has no character alive
    raise Error::NotFoundError unless current_user.user_characters.find_by_is_alive(true)

    options = {}
    options[:include] = [:individual_habits]
    render json: UserHomeSerializer.new(current_user, options).serialized_json
  end
end
