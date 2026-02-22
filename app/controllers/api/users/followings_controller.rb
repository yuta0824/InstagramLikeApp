class Api::Users::FollowingsController < ApplicationController
  include RelationshipCursorPagination

  PER_PAGE = 20

  def index
    user = User.find(params[:user_id])
    paginate_relationships(user, association: :following_relationships, target: :following, response_key: :followings)
  end
end
