# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sitepress/version'

Gem::Specification.new do |spec|
  spec.name          = "sitepress"
  spec.version       = Sitepress::VERSION
  spec.authors       = ["Brad Gessler"]
  spec.email         = ["bradgessler@gmail.com"]

  spec.summary       = %q{An embeddable file-backed content management system.}
  spec.homepage      = "https://github.com/sitepress/sitepress"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sitepress-cli", spec.version
end
