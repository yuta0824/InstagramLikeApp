class Api::Auth::LoginController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    service = params[:service]
    return redirect_to user_google_oauth2_omniauth_authorize_path if service == 'google'
    render json: { error: 'Unsupported service' }, status: :bad_request
  end
end
