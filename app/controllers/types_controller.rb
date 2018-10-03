# frozen_string_literal: true

class TypesController < ApplicationController
  before_action :set_type, only: %i[show update destroy]

  # GET /types
  def index
    types = Type.all

    render json: TypeSerializer.new(types).serialized_json
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_type
    raise Error::NotFoundError unless (@type = Type.find(params[:id]))
  end
end
