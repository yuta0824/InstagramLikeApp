class PostsController < ApplicationController
  def index
    @user = current_user
  end

  def new
    @user = current_user
    # @post = current_user.posts.build
  end
end
