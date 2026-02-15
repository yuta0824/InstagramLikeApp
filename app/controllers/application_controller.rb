class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  before_action :set_active_storage_url_options

  private

  def set_active_storage_url_options
    ActiveStorage::Current.url_options = {
      protocol: ENV['ACTIVE_STORAGE_PROTOCOL'].presence || request.scheme,
      host: ENV['ACTIVE_STORAGE_HOST'].presence || request.host,
      port: Integer(ENV['ACTIVE_STORAGE_PORT'], exception: false) || request.optional_port
    }.compact
  end
end
