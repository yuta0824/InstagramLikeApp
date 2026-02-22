class Api::TimelinesController < ApplicationController
  PER_PAGE = 20

  def index
    if params[:cursor].present? && !cursor
      render json: { errors: ['cursor is invalid'] }, status: :bad_request
      return
    end

    posts = Post
              .timeline_for(current_user)
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

  private

  def cursor
    return nil if params[:cursor].blank?

    value = Integer(params[:cursor], exception: false)
    value if value&.positive?
  end
end
