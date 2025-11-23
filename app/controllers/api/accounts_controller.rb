class Api::AccountsController < ApplicationController
  def index
    users = User.select(:id, :name).with_attached_avatar.limit(100)
    render json: users, each_serializer: UserSerializer
  end
end
