class Api::LikesController < ApplicationController
  def create
    post = Post.find(params[:post_id])
    like = post.likes.create!(user_id: current_user.id)
    render json: { is_liked: like.persisted? }
  end

  def destroy
    post = Post.find(params[:post_id])
    like = post.likes.find_by!(user_id: current_user.id)
    like.destroy!
    render json: { is_liked: like.persisted? }
  end
end
