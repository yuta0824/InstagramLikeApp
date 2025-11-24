class Api::RelationshipsController < ApplicationController
  def create
    user = User.find(params[:account_id])
    current_user.follow!(user)
    head :created
  end

  def destroy
    user = User.find(params[:account_id])
    current_user.unfollow!(user)
    head :no_content
  end
end
