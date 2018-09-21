# frozen_string_literal: true

class Me::UsersController < Me::ApplicationController
  def home
    # There is no home if user has no character alive
    if !current_user.user_characters.find_by_is_alive(true)
      render json: {
        "errors": [
          {
            "status": 404,
            "code": 1,
            "title": 'No character',
            "detail": 'User has no character alive'
          }
        ]
      }, status: :not_found
    else
      options = {}
      options[:include] = [:individual_habits]
      render json: UserHomeSerializer.new(current_user, options).serialized_json
    end
  end
end
