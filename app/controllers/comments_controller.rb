class CommentsController < ApplicationController
  def index
    post = Post.find(params[:post_id])
    @comments = post.comments
  end
end
