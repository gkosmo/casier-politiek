Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' # For development. In production, specify your frontend domain

    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
