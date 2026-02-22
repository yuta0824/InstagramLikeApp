module RelationshipCursorPagination
  extend ActiveSupport::Concern

  private

  def paginate_relationships(user, association:, target:, response_key:)
    if params[:cursor].present? && !cursor
      render json: { errors: ['cursor is invalid'] }, status: :bad_request
      return
    end

    relationships = user.public_send(association)
                        .includes(target => { avatar_attachment: :blob })
                        .order(id: :desc)

    relationships = relationships.where('relationships.id < ?', cursor) if cursor
    relationships = relationships.limit(self.class::PER_PAGE + 1).to_a

    has_more = relationships.size > self.class::PER_PAGE
    relationships = relationships.first(self.class::PER_PAGE)

    users = relationships.map(&target)

    render json: {
      response_key => ActiveModelSerializers::SerializableResource.new(
        users, each_serializer: UserSerializer, following_user_ids: current_user.following_ids.to_set
      ),
      nextCursor: has_more ? relationships.last&.id&.to_s : nil,
      hasMore: has_more
    }
  end

  def cursor
    return nil if params[:cursor].blank?

    value = Integer(params[:cursor], exception: false)
    value if value&.positive?
  end
end
