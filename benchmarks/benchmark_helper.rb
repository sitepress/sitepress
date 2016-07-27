require "bundler"
Bundler.setup(:default, :test)

require "benchmark"
require "mascot"
require_relative "../support/benchmark_dsl"

include Mascot::BenchmarkDSL
