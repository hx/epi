# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'epi/version'

Gem::Specification.new do |spec|
  spec.name          = 'epi'
  spec.version       = Epi::VERSION
  spec.authors       = ['Neil E. Pearson']
  spec.email         = ['neil@helium.net.au']
  spec.summary       = %q{Epinephrine}
  spec.description   = %q{Manage your background processes}
  spec.homepage      = 'https://github.com/hx/epi'
  spec.license       = 'Apache License, Version 2.0'

  spec.files         = Dir['{lib,bin}/**/*', 'README*', 'LICENSE*', '.yardopts'] & `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'eventmachine', '~> 1.0'
end
