class CommentsController < ApplicationController
  def index
    @post = Post.find(params[:post_id])
    @comments = @post.comments.order(created_at: :asc).includes(:user)
  end
end
