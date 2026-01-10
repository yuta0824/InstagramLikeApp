class Api::PostsController < ApplicationController
  def show
    post = Post
             .with_associations
             .includes(comments: [user: { avatar_attachment: :blob }])
             .find(params[:id])

    render json: post, serializer: PostDetailSerializer, scope: current_user, status: :ok
  end

  def create
    post = current_user.posts.new(post_params)

    if post.save
      render json: { id: post.id }, status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.fetch(:post, params).permit(:caption, images: [])
  end
end
