class Api::UsersController < ApplicationController
  def index
    users = User.select(:id, :name, :created_at).with_attached_avatar.order(created_at: :desc).limit(100)
    users = users.search_by_name(params[:q]) if params[:q].present?
    render json: users, each_serializer: UserSerializer, following_user_ids: current_user.following_ids.to_set
  end

  def show
    user = User.with_attached_avatar.find(params[:id])
    render json: user, serializer: UserDetailSerializer, following_user_ids: current_user.following_ids.to_set
  end
end
