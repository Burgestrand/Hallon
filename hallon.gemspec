# -*- encoding: utf-8 -*-
require './lib/hallon/version'

Gem::Specification.new do |gem|
  gem.name     = "hallon"
  gem.summary  = %Q{Delicious Ruby bindings to the official Spotify API}
  gem.homepage = "http://github.com/Burgestrand/Hallon"
  gem.authors  = ["Kim Burgestrand"]
  gem.email    = 'kim@burgestrand.se'
  gem.license  = 'GNU AGPL'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = []
  gem.require_paths = ["lib"]

  gem.version     = Hallon::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.required_ruby_version = '~> 1.8'

  gem.add_dependency 'spotify', '~> 8.0.5'
  gem.add_development_dependency 'mockspotify', '~> 0.1.7'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rspec', '~> 2'
  gem.add_development_dependency 'autotest-standalone'
  gem.add_development_dependency 'autotest-growl'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'rdiscount'
end
