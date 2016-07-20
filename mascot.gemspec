# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mascot/version'

Gem::Specification.new do |spec|
  spec.name          = "mascot"
  spec.version       = Mascot::VERSION
  spec.authors       = ["Brad Gessler"]
  spec.email         = ["bradgessler@gmail.com"]

  spec.summary       = %q{An embeddable file-backed content management system.}
  spec.homepage      = "https://github.com/bradgessler/mascot"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "haml", "~> 4.0"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rack"
  spec.add_development_dependency "actionpack", "~> 4.2"

  spec.add_dependency "tilt"
end
