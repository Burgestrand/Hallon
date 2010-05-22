# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version  = "0.1.0"
  
  # metadata
  gem.name     = 'Hallon'
  gem.summary  = 'Delicious Ruby bindings for libspotify'
  gem.homepage = 'http://github.com/Burgestrand/Hallon'
  gem.author   = 'Kim Burgestrand'
  gem.email    = 'kim@burgestrand.se'
  gem.description = IO.read('./README.markdown')
  gem.licenses = ['GNU AGPL']
  
  # development
  gem.add_development_dependency 'rspec'
  
  # installation
  gem.extensions    = %w(ext/extconf.rb)
  gem.files         = %w(ext/extconf.rb ext/hallon.c) + Dir['lib/**']
  
  # documentation
  gem.extra_rdoc_files = %w(ext/hallon.c)
  gem.rdoc_options = ['--charset=UTF-8']
  
  # tests
  gem.test_files = Dir['spec/*.rb']
end