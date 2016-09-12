$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require "sitepress"

require "codeclimate-test-reporter"
CodeClimate::TestReporter.configure do |config|
  config.git_dir = `git rev-parse --show-toplevel`.strip
end
CodeClimate::TestReporter.start

# TODO: Move into a support file.
RSpec::Matchers.define :have_children do |expected|
  match do |actual|
    actual.children.map(&:formats).map(&:to_a).flatten.map(&:request_path) == expected
  end
  failure_message do |actual|
    "expected children #{actual.children.map(&:formats).map(&:to_a).flatten.map(&:request_path)} to be #{expected}"
  end
end

RSpec::Matchers.define :have_siblings do |expected|
  match do |actual|
    actual.siblings.map(&:formats).map(&:to_a).flatten.map(&:request_path) == expected
  end
  failure_message do |actual|
    "expected siblings #{actual.siblings.map(&:formats).map(&:to_a).flatten.map(&:request_path)} to be #{expected}"
  end
end

RSpec::Matchers.define :have_parents do |expected|
  match do |actual|
    actual.parents.map(&:formats).map(&:to_a).flatten.map{ |r| r.request_path} == expected
  end
  failure_message do |actual|
    "expected parent #{actual.parents.map(&:formats).map(&:to_a).flatten.map(&:request_path)} to be #{expected}"
  end
end
