class Api::MeController < ApplicationController
  def show
    render json: current_user, serializer: UserDetailSerializer, following_user_ids: Set.new
  end

  def update
    ActiveRecord::Base.transaction do
      current_user.avatar.purge if remove_avatar?
      current_user.update!(me_params)
    end
    render json: current_user, serializer: UserDetailSerializer, following_user_ids: Set.new
  end

  private

  def me_params
    params.permit(:name, :avatar)
  end

  def remove_avatar?
    params[:remove_avatar] == 'true'
  end
end
