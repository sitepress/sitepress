$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rspec/rails"
require "pry"

Rails.application.configure do
  # Why set to true? Because according to Rails:
  #
  #  .config.eager_load is set to nil. Please update your config/environments/*.rb files accordingly:
  #
  #    * development - set it to false
  #    * test - set it to false (unless you use a tool that preloads your test environment)
  #   * production - set it to true
  #
  # The view initializer for haml runs in a `ActiveSupport.on_load(:action_view)`, which requires
  # `eager_load = true` to test.
  config.eager_load = true
end

# Suppress error output during testing.
Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.before(:each) do
    Rails.application.reload_routes!
  end
  config.after(:each) do
    Sitepress.reset_configuration
  end
end
