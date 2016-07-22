# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require File.expand_path('../../mascot/lib/mascot/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "mascot-rails"
  spec.version       = Mascot::VERSION
  spec.authors       = ["Brad Gessler"]
  spec.email         = ["bradgessler@gmail.com"]

  spec.summary       = %q{Mascot rails integration.}
  spec.homepage      = "https://github.com/bradgessler/mascot"

  spec.files         = Dir["{app,config,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.test_files = Dir["spec/**/*"]

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rspec-rails"

  spec.add_runtime_dependency "rails", "~> 4.2.0"
  spec.add_runtime_dependency "mascot", spec.version
end
