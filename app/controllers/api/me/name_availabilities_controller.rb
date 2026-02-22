class Api::Me::NameAvailabilitiesController < ApplicationController
  NAME_FORMAT = /\A[a-zA-Z0-9_]+\z/
  NAME_MAX_LENGTH = 20

  def show
    name = params[:name].to_s.strip
    if name.blank?
      render json: { errors: ['name is required'] }, status: :bad_request
      return
    end

    unless name.match?(NAME_FORMAT) && name.length <= NAME_MAX_LENGTH
      render json: { available: false }
      return
    end

    available = !User.where.not(id: current_user.id)
                     .where('LOWER(name) = LOWER(?)', name)
                     .exists?
    render json: { available: available }
  end
end
