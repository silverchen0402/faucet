require File.expand_path('../boot', __FILE__)

require 'rails/all'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

faucet_conf = ERB.new(File.read(File.expand_path('config/faucet.yml'))).result
FAUCETCONF = OpenStruct.new(YAML.load(faucet_conf))

module Faucet
    class Application < Rails::Application
        # Settings in config/environments/* take precedence over those specified here.
        # Application configuration should go into files in config/initializers
        # -- all .rb files in that directory are automatically loaded.

        # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
        # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
        # config.time_zone = 'Central Time (US & Canada)'

        # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
        # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
        # config.i18n.default_locale = :de

        config.middleware.use Rack::Attack

        # Do not swallow errors in after_commit/after_rollback callbacks.
        config.active_record.raise_in_transactional_callbacks = true

        config.action_mailer.default_url_options = {host: FAUCETCONF.default_url, port: FAUCETCONF.default_port}
        config.action_mailer.delivery_method = :smtp
        config.action_mailer.perform_deliveries = true
        config.action_mailer.raise_delivery_errors = true
        config.action_mailer.default_options = {from: 'no-reply@faucet.example.com'}
        config.action_mailer.smtp_settings = {
            address: FAUCETCONF.smtp['host'],
            port: '587',
            domain: FAUCETCONF.default_url,
            user_name: FAUCETCONF.smtp['user_name'],
            password: FAUCETCONF.smtp['password'],
            authentication: :plain,
            enable_starttls_auto: true
        }
        routes.default_url_options = config.action_mailer.default_url_options
        config.faucet = FAUCETCONF
        config.logger = Logger.new(STDOUT)
        config.log_level = :debug

    end
end
