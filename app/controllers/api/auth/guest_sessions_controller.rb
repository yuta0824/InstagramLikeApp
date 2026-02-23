class Api::Auth::GuestSessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    user = User.create_guest_user
    token, payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
    render json: { jwt: token, exp: payload['exp'] }, status: :created
  end
end
