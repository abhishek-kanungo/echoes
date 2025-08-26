require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Echoes
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0
    config.active_job.queue_adapter = :sidekiq

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.eager_load_paths += %W[
      #{config.root}/app/contexts
      #{config.root}/app/domains
      #{config.root}/lib
    ]

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.active_record.schema_format = :sql

    # Enable cookies and session for OmniAuth in API mode
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, key: '_echoes_session'
    config.middleware.use OmniAuth::Builder do
      provider :google_oauth2,
        Rails.application.credentials.google_oauth[:client_id],
        Rails.application.credentials.google_oauth[:client_secret],
        {
          redirect_uri: "http://localhost:3001/auth/google_oauth2/callback",
          provider_ignores_state: true,  
          scope: 'openid email profile https://www.googleapis.com/auth/user.birthday.read https://www.googleapis.com/auth/user.gender.read',
          prompt: 'consent',
          access_type: 'offline'        }
    end
    OmniAuth.config.allowed_request_methods = [:get]
    OmniAuth.config.silence_get_warning = true
        
  end
end
