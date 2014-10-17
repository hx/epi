# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spagmon/version'

Gem::Specification.new do |spec|
  spec.name          = 'spagmon'
  spec.version       = Spagmon::VERSION
  spec.authors       = ['Neil E. Pearson']
  spec.email         = ['neil@helium.net.au']
  spec.summary       = %q{Spaghetti Monster}
  spec.description   = %q{Manage your background processes}
  spec.homepage      = 'https://github.com/hx/spagmon'
  spec.license       = 'Apache License, Version 2.0'

  spec.files         = Dir['{lib,bin}/**/*'] & `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

end
