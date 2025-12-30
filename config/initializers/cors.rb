origin =
  if Rails.env.production?
    ENV.fetch('FRONTEND_URL')
  else
    ENV.fetch('FRONTEND_URL', 'http://localhost:3000')
  end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins origin
    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             expose: %w[Authorization]
  end
end
