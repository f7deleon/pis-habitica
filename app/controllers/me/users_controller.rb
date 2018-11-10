# frozen_string_literal: true

class Me::UsersController < Me::ApplicationController
  def home
    # There is no home if user has no character created
    unless current_user.user_characters.any?
      raise Error::CustomError.new(I18n.t('not_found'), '404',
                                   I18n.t('errors.messages.no_character_created'))
    end
    render json: UserHomeSerializer.new(current_user).serialized_json
  end
end
