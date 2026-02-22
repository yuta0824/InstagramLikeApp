class Api::Users::FollowersController < ApplicationController
  include RelationshipCursorPagination

  PER_PAGE = 20

  def index
    user = User.find(params[:user_id])
    paginate_relationships(user, association: :follower_relationships, target: :follower, response_key: :followers)
  end
end
