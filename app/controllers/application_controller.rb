class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  before_action :set_active_storage_url_options

  rescue_from ActiveRecord::RecordNotFound do
    render json: { errors: ['Not found'] }, status: :not_found
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def set_active_storage_url_options
    ActiveStorage::Current.url_options = {
      protocol: ENV['ACTIVE_STORAGE_PROTOCOL'].presence || request.scheme,
      host: ENV['ACTIVE_STORAGE_HOST'].presence || request.host,
      port: Integer(ENV['ACTIVE_STORAGE_PORT'], exception: false) || request.optional_port
    }.compact
  end
end
