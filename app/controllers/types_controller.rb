# frozen_string_literal: true

class TypesController < ApplicationController
  before_action :set_type, only: %i[show update destroy]

  # GET /types
  def index
    types = Type.all

    render json: TypeSerializer.new(types).serialized_json
  end

  # GET /types/1
  def show
    render json: @type
  end

  # POST /types
  def create
    raise Error::ConflictError unless (type = Type.new(type_params))

    render json: type, status: :created, location: @type
  end

  # PATCH/PUT /types/1
  def update
    if @type.update(type_params)
      render json: @type
    else
      render json: @type.errors, status: :unprocessable_entity
    end
  end

  # DELETE /types/1
  def destroy
    @type.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_type
    raise Error::NotFoundError unless (@type = Type.find(params[:id]))
  end

  # Only allow a trusted parameter "white list" through.
  def type_params
    params.require(:type).permit(:name, :description)
    raise ActionController::ParameterMissing
  end
end
