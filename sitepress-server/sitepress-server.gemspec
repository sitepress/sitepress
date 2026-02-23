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
  spec.summary       = %q{Falcon-based development server for Sitepress with process supervision and live reload.}
  spec.homepage      = "https://sitepress.cc/"

  spec.metadata["homepage_uri"]     = spec.homepage
  spec.metadata["source_code_uri"]  = "https://github.com/sitepress/sitepress"
  spec.metadata["changelog_uri"]    = "https://github.com/sitepress/sitepress/tags"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  # Falcon web server
  spec.add_runtime_dependency "falcon", ">= 0.47"
  spec.add_runtime_dependency "async", ">= 2.0"
  spec.add_runtime_dependency "async-http", ">= 0.60"

  # File watching for live reload
  spec.add_runtime_dependency "listen", ">= 3.0"
end
