$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'mascot'
require 'mascot-rails'
require 'mascot-server'

if ENV.has_key? "CODECLIMATE_REPO_TOKEN"
  puts "Initializing CodeClimate"

  require "codeclimate-test-reporter"

  # Hack so this runs on TravisCI. Details at https://github.com/codeclimate/ruby-test-reporter/issues/64
  CodeClimate::TestReporter.configure do |config|
    config.git_dir = `git rev-parse --show-toplevel`.strip
  end

  CodeClimate::TestReporter.start
end

