class ProfilesController < ApplicationController
  def show
    @user = current_user
    @posts = current_user.posts.order(created_at: :desc)
  end
end
