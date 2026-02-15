class Api::Notifications::ReadsController < ApplicationController
  def update
    notification = current_user.notifications.find(params[:notification_id])
    notification.update!(read: true)
    head :no_content
  end
end
