# frozen_string_literal: true

class Me::UsersController < Me::ApplicationController
  def home
    # There is no home if user has no character alive
    if !@user.user_characters.find_by_is_alive(true)
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
      render json: @user, serializer: UserHomeSerializer, include: ['individual_habits']
    end
  end
end
