class Api::Users::TokenExchangesController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    auth_code = params[:auth_code]
    user_id = Rails.application.config.x.redis.get("auth_code:#{auth_code}")

    unless user_id
      render json: { errors: ['auth_codeがありません。'] }, status: :unauthorized
      return
    end

    Rails.application.config.x.redis.del("auth_code:#{auth_code}")
    user = User.find(user_id)
    token, payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)

    render json: { jwt: token, exp: payload['exp'] }
  end
end
