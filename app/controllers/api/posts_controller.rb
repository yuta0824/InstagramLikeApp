class Api::PostsController < ApplicationController
  def show
    post = find_post(params[:id])
    render json: post, serializer: PostDetailSerializer, scope: current_user, status: :ok
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
      render json: updated_post, serializer: PostDetailSerializer, scope: current_user, status: :ok
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.fetch(:post, params).permit(:caption, images: [])
  end

  def find_post(id)
    Post
      .with_associations
      .includes(comments: [user: { avatar_attachment: :blob }])
      .find(id)
  end
end
