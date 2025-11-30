require 'openssl'

redis_url = ENV['REDIS_TLS_URL']
redis_url = ENV['REDIS_URL'] if redis_url.nil? || redis_url.empty?
redis_url ||= 'redis://localhost:6380'

redis_config = { url: redis_url }

if redis_url.start_with?('rediss://')
  ca_file = ENV['REDIS_SSL_CA_FILE'] || ENV['HEROKU_REDIS_CA_BUNDLE']
  ssl_params = { verify_mode: OpenSSL::SSL::VERIFY_PEER }
  ssl_params[:ca_file] = ca_file if ca_file && !ca_file.empty? && File.exist?(ca_file)
  redis_config[:ssl_params] = ssl_params
end

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
