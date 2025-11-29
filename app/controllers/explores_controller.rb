class ExploresController < ApplicationController
  def show
    suggested_users = User.where.not(id: current_user.id).includes(:posts)
    @users = suggested_users.order(Arel.sql('RANDOM()')).limit(50)
  end
end
