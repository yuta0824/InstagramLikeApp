class ProfilesController < ApplicationController
  def show
    @user = User.find(params[:id])
    @posts = @user.posts.includes(:user, likes: :user).with_attached_images.order(created_at: :desc)
  end
end
