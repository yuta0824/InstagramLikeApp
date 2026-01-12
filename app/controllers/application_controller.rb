class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  before_action :set_locale
  before_action :set_active_storage_url_options

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  private

  def set_locale
    requested_locale = params[:locale]
    stored_locale = session[:locale]

    I18n.locale =
      if requested_locale && locale_available?(requested_locale)
        requested_locale
      elsif stored_locale && locale_available?(stored_locale)
        stored_locale
      else
        I18n.default_locale
      end
    session[:locale] = I18n.locale
  end

  def locale_available?(locale)
    I18n.available_locales.any? { |available_locale| available_locale.to_s == locale.to_s }
  end

  def set_active_storage_url_options
    ActiveStorage::Current.url_options = {
      protocol: ENV['ACTIVE_STORAGE_PROTOCOL'].presence || request.scheme,
      host: ENV['ACTIVE_STORAGE_HOST'].presence || request.host,
      port: Integer(ENV['ACTIVE_STORAGE_PORT'], exception: false) || request.optional_port
    }.compact
  end
end
