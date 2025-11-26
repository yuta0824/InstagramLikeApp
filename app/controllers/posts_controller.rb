class PostsController < ApplicationController
  def index
    # フォローしてるユーザーが24時間以内に投稿したいいねが多い5記事を新着順で表示
    popular_scope = Post.by_users(current_user.followings)
                        .recent_within(24.hours)
                        .popular(limit: 5)

    @posts = Post.from(popular_scope, :posts)
                 .with_associations
                 .reorder('posts.created_at DESC')
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
