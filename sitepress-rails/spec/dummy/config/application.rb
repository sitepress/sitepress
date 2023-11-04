require_relative 'boot'

require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)
require "sitepress-rails"
require "phlex-rails"

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths << "#{root}/app/views"
    config.autoload_paths << "#{root}/app/views/layouts"
    config.autoload_paths << "#{root}/app/views/components"
  end
end
