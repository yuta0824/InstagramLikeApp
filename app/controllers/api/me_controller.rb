class Api::MeController < ApplicationController
  def show
    render json: current_user, serializer: UserSerializer
  end

  def update
    current_user.update!(me_params)
    render json: current_user, serializer: UserSerializer
  end

  private

  def me_params
    params.permit(:name, :avatar)
  end
end
