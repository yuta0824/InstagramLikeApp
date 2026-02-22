class Api::Users::PostsController < ApplicationController
  include CursorPagination

  PER_PAGE = 20

  def index
    user = User.find(params[:user_id])

    return unless validate_cursor!

    posts = user.posts
                .with_list
                .order(id: :desc)

    posts = posts.where('posts.id < ?', cursor) if cursor
    posts = posts.limit(PER_PAGE + 1).to_a

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
end
