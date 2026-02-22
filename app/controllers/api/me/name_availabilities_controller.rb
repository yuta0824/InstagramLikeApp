class Api::Me::NameAvailabilitiesController < ApplicationController
  def show
    name = params[:name].to_s.strip
    if name.blank?
      render json: { errors: ['name is required'] }, status: :bad_request
      return
    end

    available = !User.where.not(id: current_user.id)
                     .where('LOWER(name) = LOWER(?)', name)
                     .exists?
    render json: { available: available }
  end
end
