class Api::CommentsController < ApplicationController
  def create
    post = Post.find(params[:post_id])
    comment = current_user.comments.build(comment_params.merge(post: post))
    comment.save!
    render json: comment
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
