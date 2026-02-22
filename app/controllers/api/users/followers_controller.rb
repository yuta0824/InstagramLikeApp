class Api::Users::FollowersController < ApplicationController
  PER_PAGE = 20

  def index
    user = User.find(params[:user_id])

    if params[:cursor].present? && !cursor
      render json: { errors: ['cursor is invalid'] }, status: :bad_request
      return
    end

    relationships = user.follower_relationships
                        .includes(follower: { avatar_attachment: :blob })
                        .order(id: :desc)

    relationships = relationships.where('relationships.id < ?', cursor) if cursor
    relationships = relationships.limit(PER_PAGE + 1).to_a

    has_more = relationships.size > PER_PAGE
    relationships = relationships.first(PER_PAGE)

    followers = relationships.map(&:follower)

    render json: {
      followers: ActiveModelSerializers::SerializableResource.new(
        followers, each_serializer: UserSerializer, following_user_ids: current_user.following_ids.to_set
      ),
      nextCursor: has_more ? relationships.last&.id&.to_s : nil,
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
