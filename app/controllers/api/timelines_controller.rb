class Api::TimelinesController < ApplicationController
  PER_PAGE = 20

  def index
    posts = Post
              .timeline_for(current_user)
              .with_list
              .then { |rel| cursor ? rel.where('posts.id < ?', cursor) : rel }
              .order(id: :desc)
              .limit(PER_PAGE + 1)

    has_more = posts.size > PER_PAGE
    posts = posts.first(PER_PAGE)

    render json: {
      posts: ActiveModelSerializers::SerializableResource.new(
        posts, each_serializer: PostSerializer, scope: current_user
      ),
      nextCursor: has_more ? posts.last&.id&.to_s : nil,
      hasMore: has_more
    }
  end

  private

  def cursor
    params[:cursor]&.to_i
  end
end
