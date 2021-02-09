# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require File.expand_path('../../sitepress-core/lib/sitepress/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "sitepress-server"
  spec.version       = Sitepress::VERSION
  spec.authors       = ["Brad Gessler"]
  spec.email         = ["bradgessler@gmail.com"]

  spec.summary       = %q{Sitepress rack app for stand-alone of embedded usage.}
  spec.homepage      = "https://github.com/sitepress/sitepress"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "haml", "~> 5.0"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rack"

  spec.add_development_dependency "haml-rails"
  spec.add_development_dependency "sass-rails"
  spec.add_development_dependency "markdown-rails"

  spec.add_dependency "sitepress-rails", spec.version

  # We don't need every single rals rependency, so grab the subset here.
  rails_version      = ">= 5.0"
  spec.add_dependency "railties",       rails_version
  spec.add_dependency "activesupport",  rails_version
  spec.add_dependency "actionpack",     rails_version
  spec.add_dependency "actionview",     rails_version
  spec.add_dependency "activemodel",    rails_version
end
