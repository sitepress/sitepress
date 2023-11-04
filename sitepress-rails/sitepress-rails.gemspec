# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require File.expand_path('../../sitepress-core/lib/sitepress/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "sitepress-rails"
  spec.version       = Sitepress::VERSION
  spec.authors       = ["Brad Gessler"]
  spec.email         = ["bradgessler@gmail.com"]
  spec.licenses      = ["MIT"]
  spec.summary       = %q{Sitepress rails integration.}
  spec.homepage      = "https://sitepress.cc/"

  spec.metadata["homepage_uri"]     = spec.homepage
  spec.metadata["source_code_uri"]  = "https://github.com/sitepress/sitepress"
  spec.metadata["changelog_uri"]    = "https://github.com/sitepress/sitepress/tags"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.test_files = Dir["spec/**/*"]

  rails_version      = ">= 6.0"

  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rails", rails_version
  spec.add_development_dependency "phlex-rails"

  spec.add_runtime_dependency "sitepress-core", spec.version

  # We don't need every single rals rependency, so grab the subset here.
  spec.add_dependency "railties",       rails_version
  spec.add_dependency "actionpack",     rails_version
  spec.add_dependency "sprockets-rails", ">= 2.0.0"
end
