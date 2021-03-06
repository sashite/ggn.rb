Gem::Specification.new do |spec|
  spec.name          = 'sashite-ggn'
  spec.version       = File.read('VERSION.semver')
  spec.authors       = ['Cyril Wack']
  spec.email         = ['contact@cyril.io']
  spec.summary       = %q{Some mappers for GGN objects}
  spec.description   = %q{A Ruby interface for GGN (General Gameplay Notation) objects.}
  spec.homepage      = 'https://github.com/sashite/ggn.rb'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',  '~> 1.6'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'rake',     '~> 10'
end
