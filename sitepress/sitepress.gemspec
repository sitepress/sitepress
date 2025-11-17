# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require File.expand_path('../../sitepress-core/lib/sitepress/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "sitepress"
  spec.version       = Sitepress::VERSION
  spec.authors       = ["Brad Gessler"]
  spec.email         = ["bradgessler@gmail.com"]
  spec.licenses      = ["MIT"]
  spec.summary       = %q{An embeddable file-backed content management system.}
  spec.homepage      = "https://sitepress.cc/"

  spec.metadata["homepage_uri"]     = spec.homepage
  spec.metadata["source_code_uri"]  = "https://github.com/sitepress/sitepress"
  spec.metadata["changelog_uri"]    = "https://github.com/sitepress/sitepress/tags"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Core dependencies
  spec.add_runtime_dependency "sitepress-core", spec.version
  spec.add_runtime_dependency "sitepress-rails", spec.version
  
  # CLI dependencies (from sitepress-cli)
  spec.add_runtime_dependency "thor", ">= 1.0.0"
  spec.add_runtime_dependency "rack", ">= 1.0.0", "< 3.0.0"
  
  # Development dependencies
  spec.add_development_dependency "rack-test"
end