url =
  if Rails.env.production?
    ENV.fetch('REDIS_URL')
  else
    ENV.fetch('REDIS_URL', 'redis://localhost:6379/1')
  end

Rails.application.config.x.redis = Redis.new(url:)
