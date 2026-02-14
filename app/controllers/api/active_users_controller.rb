class Api::ActiveUsersController < ApplicationController
  def index
    limit = [params.fetch(:limit, 30).to_i, 30].min
    active_users = User.recently_active(limit:).with_attached_avatar
    render json: active_users, each_serializer: UserSerializer
  end
end
