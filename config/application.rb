require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sysbuilder
  class Application < Rails::Application
    require "#{config.root}/lib/hash"

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    #
    # Auto-require all libraries in the lib/ directory
    config.autoload_paths << Rails.root.join('lib')

    # Configure the Faye pub/sub server
    config.middleware.delete Rack::Lock
    config.middleware.use FayeRails::Middleware, mount: '/faye', :timeout => 25 do
      # routing for querying the launch status
      map '/build_status' => RealtimeBuildsController

      class ServerAuth
        def incoming(message, callback)
          if message['channel'] !~ %r{^/meta/}
            if message['ext']['auth_token'] != FAYE_TOKEN
              message['error'] = 'Invalid authentication token'
            end
          end
          callback.call(message)
        end

        # IMPORTANT: clear out the auth token so it is not leaked to the client
        def outgoing(message, callback)
          if message['ext'] && message['ext']['auth_token']
            message['ext'] = {}
          end
          callback.call(message)
        end
      end

      add_extension(ServerAuth.new)
    end
  end
end
