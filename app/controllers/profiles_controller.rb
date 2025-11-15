class ProfilesController < ApplicationController
  def show
    @user = current_user
    @posts = current_user.posts
                         .includes(:user, likes: :user)
                         .with_attached_images
                         .order(created_at: :desc)
  end
end
