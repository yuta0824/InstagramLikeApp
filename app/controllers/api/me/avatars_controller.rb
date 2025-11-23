class Api::Me::AvatarsController < ApplicationController
  def update
    current_user.update!(user_params)
    render json: { avatar_url: current_user.avatar_url }
  end

  private

  def user_params
    params.permit(:avatar)
  end
end
