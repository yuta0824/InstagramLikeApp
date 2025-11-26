class ExploresController < ApplicationController
  def show
    @users = User.where.not(id: current_user.id).includes(:posts)

    if params[:query].present?
      @users = @users.where('name LIKE ?', "%#{params[:query]}%")
    end

    @users = @users.order(Arel.sql('RANDOM()')).limit(50)
  end
end
