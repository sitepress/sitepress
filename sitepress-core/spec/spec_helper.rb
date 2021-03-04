$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require "sitepress-core"

require 'simplecov'
SimpleCov.start

# TODO: Move into a support file.
RSpec::Matchers.define :have_children do |expected|
  match do |actual|
    actual.children.map(&:formats).map(&:to_a).flatten.map(&:request_path).sort == expected.sort
  end
  failure_message do |actual|
    "expected children #{actual.children.map(&:formats).map(&:to_a).flatten.map(&:request_path)} to be #{expected}"
  end
end

RSpec::Matchers.define :have_siblings do |expected|
  match do |actual|
    actual.siblings.map(&:formats).map(&:to_a).flatten.map(&:request_path).sort == expected.sort
  end
  failure_message do |actual|
    "expected siblings #{actual.siblings.map(&:formats).map(&:to_a).flatten.map(&:request_path)} to be #{expected}"
  end
end

RSpec::Matchers.define :have_parents do |expected|
  match do |actual|
    actual.parents.map(&:formats).map(&:to_a).flatten.map{ |r| r.request_path}.sort == expected.sort
  end
  failure_message do |actual|
    "expected parent #{actual.parents.map(&:formats).map(&:to_a).flatten.map(&:request_path)} to be #{expected}"
  end
end
