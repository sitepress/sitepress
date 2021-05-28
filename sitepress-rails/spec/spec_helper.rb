$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rspec/rails"
require "pry"

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
