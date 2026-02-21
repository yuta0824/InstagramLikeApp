class Api::Posts::CommentsController < ApplicationController
  def create
    post = Post.find(params[:post_id])
    comment = current_user.comments.build(comment_params.merge(post: post))

    if comment.save
      Notification.notify_if_needed(actor: current_user, recipient: post.user, notifiable: comment, notification_type: :commented)
      render json: comment, scope: current_user, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

 def destroy
    comment = current_user.comments.find(params[:id])
    comment.destroy!
    head :no_content
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
