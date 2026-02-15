class Api::NotificationsController < ApplicationController
  PER_PAGE = 20

  def index
    notifications = current_user.notifications
                                .with_details
                                .recent_first
                                .limit(PER_PAGE)
                                .offset(offset)
    render json: notifications, each_serializer: NotificationSerializer
  end

  private

  def offset
    page = [params.fetch(:page, 1).to_i, 1].max
    (page - 1) * PER_PAGE
  end
end
