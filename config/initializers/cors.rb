# config/initializers/cors.rb
# Allow cross-origin requests for API access from TUI clients

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*"

    resource "/api/*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ["Content-Type"]
  end
end
