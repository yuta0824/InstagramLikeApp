class PostsController < ApplicationController
  def index
    # フォローしてるユーザーが24時間以内に投稿したいいねが多い5記事を新着順で表示
    following_posts = Post.where(user_id: current_user.followings)
    recent_posts = recent_posts(following_posts)
    popular_ids = popular_post_ids(recent_posts)
    @posts = Post.where(id: popular_ids)
                 .includes(:user, likes: :user)
                 .with_attached_images
                 .order('posts.created_at DESC')
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

  def recent_posts(posts)
    posts.where('posts.created_at >= ?', 24.hours.ago)
  end

  def popular_post_ids(posts)
    posts.left_joins(:likes)
      .group('posts.id')
      .order('COUNT(likes.id) DESC, posts.created_at DESC')
      .limit(5)
      .pluck(:id)
  end
end
