Rails.application.config.x.redis = Redis.new(url: ENV.fetch('REDIS_URL'))
