class Api::Posts::LikesController < ApplicationController
  def create
    post = Post.find(params[:post_id])
    like = post.likes.create!(user_id: current_user.id)
    render json: { isLiked: like.persisted? }
  end

  def destroy
    post = Post.find(params[:post_id])
    like = post.likes.find_by!(user_id: current_user.id)
    like.destroy!
    render json: { isLiked: like.persisted? }
  end
end
