# encoding: utf-8

Gem::Specification.new do |gem|
  gem.version  = "0.1.0"
  gem.required_rubygems_version = ">= 1.3.6"
  gem.required_ruby_version = ">= 1.8"
  
  # metadata
  gem.name     = 'hallon'
  gem.summary  = 'Delicious Ruby bindings for libspotify'
  gem.homepage = 'http://github.com/Burgestrand/Hallon'
  gem.author   = 'Kim Burgestrand'
  gem.email    = 'kim@burgestrand.se'
  gem.license  = 'GNU AGPL'
  
  gem.description = IO.read('./README.markdown')
  gem.description = gem.description.force_encoding 'UTF-8' if gem.description.respond_to?(:force_encoding)
  
  # development
  gem.add_dependency 'rspec'
  
  # installation
  gem.extensions    = %w(ext/extconf.rb)
  gem.files         = Dir['lib/*.rb']
  
  # documentation
  gem.extra_rdoc_files = %w(ext/hallon.c)
  gem.rdoc_options = ['--charset=UTF-8']
  
  # tests
  gem.test_files = Dir['spec/*.rb']
end