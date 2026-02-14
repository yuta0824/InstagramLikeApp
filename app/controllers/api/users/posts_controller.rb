class Api::Users::PostsController < ApplicationController
  PER_PAGE = 20

  def index
    user = User.find(params[:user_id])
    page = [params.fetch(:page, 1).to_i, 1].max
    posts = user.posts
                .with_associations.includes(comments: [user: { avatar_attachment: :blob }])
                .order(created_at: :desc)
                .offset((page - 1) * PER_PAGE)
                .limit(PER_PAGE)
    render json: posts, each_serializer: PostDetailSerializer, scope: current_user, status: :ok
  end
end
