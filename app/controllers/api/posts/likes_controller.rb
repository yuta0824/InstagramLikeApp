class Api::Posts::LikesController < ApplicationController
  def create
    post = Post.find(params[:post_id])
    like = post.likes.create!(user_id: current_user.id)
    Notification.notify_if_needed(actor: current_user, recipient: post.user, notifiable: like, notification_type: :liked)
    render json: { isLiked: like.persisted? }
  end

  def destroy
    post = Post.find(params[:post_id])
    like = post.likes.find_by!(user_id: current_user.id)
    like.destroy!
    Notification.retract_if_needed(actor: current_user, recipient: post.user, target_post_id: post.id)
    render json: { isLiked: like.persisted? }
  end
end
