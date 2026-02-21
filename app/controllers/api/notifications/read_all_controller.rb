class Api::Notifications::ReadAllController < ApplicationController
  def create
    current_user.notifications.unread.update_all(read: true)
    head :no_content
  end
end
