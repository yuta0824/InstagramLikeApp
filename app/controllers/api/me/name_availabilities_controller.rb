class Api::Me::NameAvailabilitiesController < ApplicationController
  def show
    available = !User.where.not(id: current_user.id).exists?(name: params[:name])
    render json: { available: available }
  end
end
