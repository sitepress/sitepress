require "bundler"
Bundler.setup(:default, :test)

require "benchmark"
require "sitepress-core"
require_relative "../support/benchmark_dsl"

include Sitepress::BenchmarkDSL
