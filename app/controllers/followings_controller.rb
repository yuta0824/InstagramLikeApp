class FollowingsController < ApplicationController
  def index
    @user = User.find_by!(name: params[:account_username])
    @followings = @user.followings.with_attached_avatar.includes(:posts)
  end
end
