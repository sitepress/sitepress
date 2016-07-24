$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require 'rspec/rails'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.after(:each) do
    Mascot.instance_variable_set(:@configuration, nil)
    Rails.application.reload_routes!
  end
end

require "codeclimate-test-reporter"
CodeClimate::TestReporter.configure do |config|
  config.git_dir = `git rev-parse --show-toplevel`.strip
end
CodeClimate::TestReporter.start
