class Api::MeController < ApplicationController
  def show
    render json: current_user, serializer: UserDetailSerializer, following_user_ids: Set.new
  end

  def update
    ActiveRecord::Base.transaction do
      current_user.update!(me_params)
      current_user.avatar.purge if remove_avatar?
    end
    render json: current_user, serializer: UserDetailSerializer, following_user_ids: Set.new
  rescue ActiveRecord::RecordInvalid
    render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def me_params
    params.permit(:name, :avatar)
  end

  def remove_avatar?
    params[:remove_avatar] == 'true'
  end
end
