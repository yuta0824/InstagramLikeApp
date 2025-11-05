class Api::AvatarsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def update
    current_user.update!(user_params)
    render json: { avatar_url: current_user.avatar_url }
  end

  private

  def user_params
    params.permit(:avatar)
  end
end
