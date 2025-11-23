class AccountsController < ApplicationController
  def show
    @user = User.find_by!(name: params[:username])
    @posts = @user.posts.includes(:user, likes: :user).with_attached_images.order(created_at: :desc)
  end
end
