class Api::PostsController < ApplicationController
  def index
    posts = Post
              .with_details
              .limit(20)
              .order(created_at: :desc)
    render json: posts, each_serializer: PostDetailSerializer, scope: current_user
  end

  def show
    post = find_post(params[:id])
    render json: post, serializer: PostDetailSerializer, scope: current_user
  end

  def create
    post = current_user.posts.new(post_params)

    if post.save
      render json: post, serializer: PostDetailSerializer, scope: current_user, status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    post = current_user.posts.find(params[:id])

    if post.update(post_params)
      updated_post = find_post(post.id)
      render json: updated_post, serializer: PostDetailSerializer, scope: current_user
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    post = current_user.posts.find(params[:id])
    post.destroy!
    head :no_content
  end

  private

  def post_params
    params.fetch(:post, params).permit(:caption, images: [])
  end

  def find_post(id)
    Post
      .with_details
      .find(id)
  end
end
