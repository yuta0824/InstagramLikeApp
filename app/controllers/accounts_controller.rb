class AccountsController < ApplicationController
  def show
    @user = User.find_by!(name: params[:username])
    @posts = @user.posts.includes(:user, likes: :user).with_attached_images.order(created_at: :desc)
    @posts_count = @user.posts.count
    @followers_count = @user.followers.count
    @followings_count = @user.followings.count
  end
end
