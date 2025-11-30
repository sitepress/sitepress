require_relative 'boot'

require "action_controller/railtie"
require "action_mailer/railtie"

# sitepress-rails is asset-pipeline agnostic. It works with Propshaft, Sprockets,
# or no asset pipeline at all. The host Rails app chooses its own asset pipeline.
# For testing, we let Bundler load whatever is available.
Bundler.require(*Rails.groups)
require "sitepress-rails"

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end

