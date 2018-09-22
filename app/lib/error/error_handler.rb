# frozen_string_literal: true

module Error
  module ErrorHandler
    def self.included(clazz)
      clazz.class_eval do
        rescue_from ActiveRecord::RecordNotFound do |e|
          klass = Object.const_get e.model
          json_response = Helpers::Render.json(
            I18n.t('not_found'),
            404,
            I18n.t('activerecord.errors.messages.not_found', model: klass.model_name.human)
          )
          respond(json_response, 404)
        end
        rescue_from ActiveRecord::RecordInvalid do |e|
          json_response = Helpers::RenderValidations.json(e)
          respond(json_response, 400)
        end
        rescue_from ActionController::ParameterMissing do |e|
          json_response = Helpers::Render.json(I18n.t('bad_request'), 400, e)
          respond(json_response, 400)
        end
        rescue_from CustomError do |e|
          json_response = Helpers::Render.json(e.error, e.status, e.message)
          respond(json_response, e.status)
        end
      end
    end

    private

    def unauthorized_entity(_error)
      json_response = CustomError.new(I18n.t('unauthorized'), 401, I18n.t('unauthorized_details')).fetch_json
      respond(json_response, 401)
    end

    def respond(json_response, status)
      render json: json_response, status: status
    end
  end
end
