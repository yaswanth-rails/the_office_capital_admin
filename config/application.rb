require_relative "boot"

require "rails/all"
require 'devise'
require "sprockets/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MyApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.time_zone = 'Chennai'
    config.active_record.default_timezone = :local
    
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.filter_parameters += [:password, :password_confirmation, :pin]
    config.middleware.delete Rack::Lock
    config.active_job.queue_adapter = :sidekiq
    # config.active_job.queue_name_prefix = Rails.env
    # config.active_job.queue_name_delimiter = '_'
    config.action_mailer.delivery_job = "ActionMailer::MailDeliveryJob"
    # config.middleware.insert_after ActionDispatch::Session::ActiveRecordStore,Faye::RackAdapter,:extensions => [CsrfProtection.new],:mount=>'/faye',:timeout    => 25
    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true
    
    # config.middleware.use Rack::RedisThrottle::Daily, max: 100000
    config.assets.configure do |env|
        env.export_concurrent = false
    end    
    config.middleware.use Rack::Attack    
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end
    config.autoload_paths << Rails.root.join('lib')
  end
end
