class Api::TimelinesController < ApplicationController
  def index
    posts = Post
              .where(user_id: timeline_user_ids)
              .or(Post.where(user_id: current_user.id))
              .with_list
              .limit(20)
              .order(created_at: :desc)
    render json: posts, each_serializer: PostSerializer, scope: current_user
  end

  private

  def timeline_user_ids
    Relationship.where(follower_id: current_user.id).select(:following_id)
  end
end
