# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec_runner/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec_runner"
  spec.version       = RspecRunner::VERSION
  spec.authors       = ["exAspArk"]
  spec.email         = ["exaspark@gmail.com"]

  spec.summary       = %q{Application preloader for running RSpec}
  spec.description   = %q{Works even with non-Rails apps}
  spec.homepage      = "https://github.com/exAspArk/rspec_runner"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.require_paths = ["lib"]
  spec.executables  << 'rspec_runner'

  spec.add_runtime_dependency 'rspec', '~> 3.0'
  spec.add_runtime_dependency 'listen', '~> 3.0'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
