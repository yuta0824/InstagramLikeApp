class Api::TimelinesController < ApplicationController
  def index
    posts = Post
              .timeline_for(current_user)
              .with_list
              .limit(20)
              .order(created_at: :desc)
    render json: posts, each_serializer: PostSerializer, scope: current_user
  end
end
