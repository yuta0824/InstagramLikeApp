class Api::CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    post = Post.find(params[:post_id])
    comment = current_user.comments.build(comment_params.merge(post: post))
    comment.save!
    render_comments(post)
  end

  def destroy
    comment = current_user.comments.find(params[:id])
    post = comment.post
    comment.destroy!
    render_comments(post)
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end

  def render_comments(post)
    comments = post.comments.includes(:user).order(created_at: :asc)
    render json: comments, each_serializer: CommentSerializer
  end
end
