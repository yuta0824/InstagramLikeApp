class FollowersController < ApplicationController
  def index
    @user = User.find_by!(name: params[:account_username])
    @followers = @user.followers
  end
end
