require "bundler"
Bundler.setup(:default, :test)

require "benchmark"
require "mascot"
require_relative "../support/fake_site_generator"
