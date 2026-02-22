class Api::Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user!

  def google_oauth2
    user = User.from_omniauth(request.env['omniauth.auth'])
    auth_code = SecureRandom.hex(16)
    Rails.application.config.x.redis.setex("auth_code:#{auth_code}", 60, user.id)
    redirect_to "#{ENV.fetch('FRONTEND_URL')}/auth-callback?auth_code=#{auth_code}", allow_other_host: true
    rescue StandardError => e
      Rails.logger.error("OmniAuth google_oauth2 failed: #{e.class} - #{e.message}")
      redirect_to "#{ENV.fetch('FRONTEND_URL')}/?auth_error=google", allow_other_host: true
  end
end
