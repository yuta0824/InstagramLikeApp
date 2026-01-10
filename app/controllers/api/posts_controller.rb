class Api::PostsController < ApplicationController
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
