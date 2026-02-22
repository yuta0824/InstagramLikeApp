class Api::Users::FollowersController < ApplicationController
  PER_PAGE = 20

  def index
    user = User.find(params[:user_id])
    page = [params.fetch(:page, 1).to_i, 1].max
    followers = user.followers
                    .with_attached_avatar
                    .order(created_at: :desc)
                    .offset((page - 1) * PER_PAGE)
                    .limit(PER_PAGE)
    render json: followers, each_serializer: UserSerializer, following_user_ids: current_user.following_ids.to_set
  end
end
