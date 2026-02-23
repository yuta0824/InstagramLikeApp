url =
  if Rails.env.production?
    ENV.fetch('REDIS_URL')
  else
    ENV.fetch('REDIS_URL', 'redis://localhost:6379/1')
  end

ssl_params = url.start_with?('rediss://') ? { verify_mode: OpenSSL::SSL::VERIFY_NONE } : {}

Rails.application.config.x.redis = Redis.new(url:, ssl_params:)
