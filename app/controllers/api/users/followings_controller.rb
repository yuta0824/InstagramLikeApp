class Api::Users::FollowingsController < ApplicationController
  PER_PAGE = 20

  def index
    user = User.find(params[:user_id])

    if params[:cursor].present? && !cursor
      render json: { errors: ['cursor is invalid'] }, status: :bad_request
      return
    end

    relationships = user.following_relationships
                        .includes(following: { avatar_attachment: :blob })
                        .order(id: :desc)

    relationships = relationships.where('relationships.id < ?', cursor) if cursor
    relationships = relationships.limit(PER_PAGE + 1).to_a

    has_more = relationships.size > PER_PAGE
    relationships = relationships.first(PER_PAGE)

    followings = relationships.map(&:following)

    render json: {
      followings: ActiveModelSerializers::SerializableResource.new(
        followings, each_serializer: UserSerializer, following_user_ids: current_user.following_ids.to_set
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
