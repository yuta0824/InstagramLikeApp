class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  before_action :set_locale

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  private

  def set_locale
    requested_locale = params[:locale] || session[:locale]
    allowed_locale = I18n.available_locales.find { |locale| locale.to_s == requested_locale.to_s }

    I18n.locale = allowed_locale || I18n.default_locale
    session[:locale] = I18n.locale
  end
end
