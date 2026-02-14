class Api::ActiveUsersController < ApplicationController
  def index
    limit = params.fetch(:limit, 30).to_i.clamp(1, 30)
    active_users = User.recently_active(limit:).with_attached_avatar
    render json: active_users, each_serializer: UserSerializer, following_user_ids: current_user.following_ids.to_set
  end
end
