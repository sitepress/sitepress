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
end

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

# From test folder...
# # Configure Rails Environment
# ENV["RAILS_ENV"] = "test"

# require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)
# ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../test/dummy/db/migrate", __FILE__)]
# ActiveRecord::Migrator.migrations_paths << File.expand_path('../../db/migrate', __FILE__)
# require "rails/test_help"

# # Filter out Minitest backtrace while allowing backtrace from other libraries
# # to be shown.
# Minitest.backtrace_filter = Minitest::BacktraceFilter.new


# # Load fixtures from the engine
# if ActiveSupport::TestCase.respond_to?(:fixture_path=)
#   ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
#   ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
#   ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
#   ActiveSupport::TestCase.fixtures :all
# end
