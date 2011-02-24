# coding: utf-8
begin require 'bundler/setup'
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems."
  exit e.status_code
end
require 'rake'

require 'jeweler'
require 'rake/extensiontask'
require './lib/hallon/version'
Jeweler::RubygemsDotOrgTasks.new
Rake::ExtensionTask.new('hallon', Jeweler::Tasks.new do |gem|
  gem.name     = "hallon"
  gem.summary  = %Q{Delicious Ruby bindings to the official Spotify API}
  gem.homepage = "http://github.com/Burgestrand/Hallon"
  gem.authors  = ["Kim Burgestrand"]
  gem.email    = 'kim@burgestrand.se'
  gem.license  = 'GNU AGPL'
  
  gem.description = IO.read('./README.markdown', encoding: 'utf-8')
  
  # installation
  gem.require_paths = %w(lib ext)
  gem.extensions = FileList['ext/**/extconf.rb']
  gem.platform   = Gem::Platform::RUBY
  gem.version    = Hallon::VERSION
  gem.required_ruby_version = '~> 1.9'
end.gemspec) do |ext|
  ext.lib_dir = File.join('lib', 'hallon')
end

require 'yard'
YARD::Rake::YardocTask.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

#
# Custom tasks
# 
desc "Do a recompile by combining :clobber and :compile"
task :recompile => [:clobber, :compile]

desc "Generates YARD documentation and open it."
task :doc => :yard do
  system 'open doc/index.html'
end

desc "Fires up watchr, allowing autotest-like behavior"
task :watchr do
  exec(*'bundle exec watchr hallon.watchr.rb'.split(' '))
end

desc "Start watchr, open a new tab and open Hallon directory in $EDITOR using terminitor"
task(:work) { system 'terminitor start' }

task :default => [:compile, :spec]