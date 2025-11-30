class ExploresController < ApplicationController
  def show
    @users = User.recently_active
                 .where.not(id: current_user.id)
                 .includes(avatar_attachment: :blob)
  end
end
