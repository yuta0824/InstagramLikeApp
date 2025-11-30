require 'openssl'

redis_url = ENV['REDIS_TLS_URL'].presence || ENV['REDIS_URL'].presence || 'redis://localhost:6380'
redis_config = { url: redis_url }

if redis_url.start_with?('rediss://')
  ca_file = ENV['REDIS_SSL_CA_FILE'].presence || ENV['HEROKU_REDIS_CA_BUNDLE'].presence

  redis_config[:ssl_params] =
    if ca_file && File.exist?(ca_file)
      { verify_mode: OpenSSL::SSL::VERIFY_PEER, ca_file: ca_file }
    else
      Rails.logger.warn('[Sidekiq] Redis TLS CA bundle not found; disabling certificate verification') if defined?(Rails)
      { verify_mode: OpenSSL::SSL::VERIFY_NONE }
    end
end

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
