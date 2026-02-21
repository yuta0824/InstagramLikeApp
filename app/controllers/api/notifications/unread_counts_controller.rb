class Api::Notifications::UnreadCountsController < ApplicationController
  def show
    count = current_user.notifications.unread.count
    render json: { unreadCount: count }
  end
end
