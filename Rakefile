# coding: utf-8
require 'rake'

require 'jeweler'
require './lib/hallon/version'
Jeweler::RubygemsDotOrgTasks.new
Jeweler::Tasks.new do |gem|
  gem.name     = "hallon"
  gem.summary  = %Q{Delicious Ruby bindings to the official Spotify API}
  gem.homepage = "http://github.com/Burgestrand/Hallon"
  gem.authors  = ["Kim Burgestrand"]
  gem.email    = 'kim@burgestrand.se'
  gem.license  = 'GNU AGPL'
  
  gem.description = IO.read('./README.markdown', encoding: 'utf-8')
  
  # installation
  gem.extensions = FileList['ext/**/extconf.rb']
  gem.platform   = Gem::Platform::RUBY
  gem.version    = Hallon::VERSION
  gem.required_ruby_version = '~> 1.9'
end

require 'yard'
YARD::Rake::YardocTask.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

#
# Custom tasks
# 
desc "Generates YARD documentation and open it."
task :doc => :yard do
  system 'open doc/index.html'
end

desc "Fires up watchr, allowing autotest-like behavior"
task :watchr do
  exec(*'bundle exec watchr hallon.watchr.rb'.split(' '))
end

desc "Start watchr, open a new tab and open Hallon directory in $EDITOR using terminitor"
task(:work) do
  Bundler.with_clean_env { system 'terminitor start' }
end

task :default => [:spec]