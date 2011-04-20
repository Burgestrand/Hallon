# -*- encoding: utf-8 -*-
require './lib/hallon/version'

Gem::Specification.new do |gem|
  gem.name     = "hallon"
  gem.summary  = %Q{Delicious Ruby bindings to the official Spotify API}
  gem.homepage = "http://github.com/Burgestrand/Hallon"
  gem.authors  = ["Kim Burgestrand"]
  gem.email    = 'kim@burgestrand.se'
  gem.license  = 'GNU AGPL'
  
  gem.description = IO.read('./README.markdown', encoding: 'utf-8')
  
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = []
  gem.require_paths = ["lib"]
  
  gem.version     = Hallon::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.required_ruby_version = '~> 1.9'
  
  gem.add_dependency 'spotify', '~> 7.0.0'
  gem.add_development_dependency 'rspec', '~> 2'
  gem.add_development_dependency 'autotest-standalone'
  gem.add_development_dependency 'autotest-growl'
  gem.add_development_dependency 'cover_me'
  gem.add_development_dependency 'yard', '~> 0.6.4'
  gem.add_development_dependency 'rdiscount'
end