class PostsController < ApplicationController
  def index
    @user = current_user
  end

  def new
    @user = current_user
    @post = current_user.posts.build
  end

  def create
    @user = current_user
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to root_path, notice: '投稿しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy!
    redirect_to root_path, notice: '削除しました'
  end

  private

  def post_params
    params.require(:post).permit(:caption, images: [])
  end
end
