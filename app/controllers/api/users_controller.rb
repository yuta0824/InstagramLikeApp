class Api::UsersController < ApplicationController
  def index
    searchable_users = User.select(:id, :name).with_attached_avatar.limit(100)
    render json: searchable_users, each_serializer: UserSerializer
  end
end
