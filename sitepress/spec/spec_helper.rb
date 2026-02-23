$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require "sitepress"
require "pry"

# macOS and Linux builds of Ruby don't deal with this the same way, probably
# because the file system iterates through paths a little differently in terms
# of how the sorted nodes come back. I don't mind that at runtime, but it causes
# CI failures, so I have to deal with those in these tests.
def order_and_format(nodes)
  nodes.map(&:formats).map(&:to_a).flatten.map(&:request_path).sort
end

RSpec::Matchers.define :have_children do |expected|
  match do |actual|
    order_and_format(actual.children) == expected
  end
  failure_message do |actual|
    "expected children #{order_and_format(actual.children)} to be #{expected}"
  end
end

RSpec::Matchers.define :have_siblings do |expected|
  match do |actual|
    order_and_format(actual.siblings) == expected
  end
  failure_message do |actual|
    "expected siblings #{order_and_format(actual.siblings)} to be #{expected}"
  end
end

RSpec::Matchers.define :have_parents do |expected|
  match do |actual|
    actual.parents.map(&:formats).map(&:to_a).flatten.map{ |r| r.request_path} == expected
  end
  failure_message do |actual|
    "expected parent #{order_and_format(actual.parents)} to be #{expected}"
  end
end
