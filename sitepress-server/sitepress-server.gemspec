# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require File.expand_path('../../sitepress-core/lib/sitepress/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "sitepress-server"
  spec.version       = Sitepress::VERSION
  spec.authors       = ["Brad Gessler"]
  spec.email         = ["bradgessler@gmail.com"]
  spec.licenses      = ["MIT"]
  spec.summary       = %q{Sitepress rack app for stand-alone of embedded usage.}
  spec.homepage      = "https://sitepress.cc/"

  spec.metadata["homepage_uri"]     = spec.homepage
  spec.metadata["source_code_uri"]  = "https://github.com/sitepress/sitepress"
  spec.metadata["changelog_uri"]    = "https://github.com/sitepress/sitepress/tags"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rack-test"

  spec.add_runtime_dependency "sitepress-rails", spec.version

  # Default asset pipeline for standalone server. The abstraction in
  # Sitepress::AssetPipeline allows users to swap this for sprockets if preferred.
  spec.add_runtime_dependency "propshaft", ">= 1.0.0"
end
