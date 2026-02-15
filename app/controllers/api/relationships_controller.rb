class Api::RelationshipsController < ApplicationController
  def create
    user = User.find(params[:user_id])
    relationship = current_user.follow!(user)
    Notification.notify_if_needed(actor: current_user, recipient: user, notifiable: relationship, notification_type: :followed)
    head :created
  end

  def destroy
    user = User.find(params[:user_id])
    current_user.unfollow!(user)
    head :no_content
  end
end
