class ExploresController < ApplicationController
  def show
    users = User.where.not(id: current_user.id).includes(:posts)
    @users = users.order(Arel.sql('RANDOM()')).limit(50)
  end
end
