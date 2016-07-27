require "bundler"
Bundler.setup(:default, :test)

require "benchmark"
require "mascot"

Dir[File.join(__dir__, "support/*.rb")].each do |path|
  require path
end
