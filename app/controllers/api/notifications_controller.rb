class Api::NotificationsController < ApplicationController
  PER_PAGE = 20

  def index
    notifications = current_user.notifications
                                .with_details
                                .recent_first
                                .offset(offset)
                                .limit(PER_PAGE + 1)
                                .to_a

    has_more = notifications.size > PER_PAGE
    notifications = notifications.first(PER_PAGE)

    actor_ids = notifications.flat_map(&:recent_actor_ids).uniq
    actors_by_id = User.where(id: actor_ids).index_by(&:id)
    render json: {
      notifications: ActiveModelSerializers::SerializableResource.new(
        notifications, each_serializer: NotificationSerializer, actors_by_id: actors_by_id
      ),
      hasMore: has_more
    }
  end

  private

  def offset
    page = [params.fetch(:page, 1).to_i, 1].max
    (page - 1) * PER_PAGE
  end
end
