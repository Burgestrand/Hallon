# coding: utf-8
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems."
  exit e.status_code
end
require 'rake'
require 'jeweler'
require 'rspec/core/rake_task'
require 'yard'
require 'rake/extensiontask'
require './lib/hallon/version'

YARD::Rake::YardocTask.new
Jeweler::RubygemsDotOrgTasks.new
RSpec::Core::RakeTask.new

# rake-compiler + jeweler
Rake::ExtensionTask.new('hallon', Jeweler::Tasks.new do |gem|
  gem.name     = "hallon"
  gem.summary  = %Q{Delicious Ruby bindings to the official Spotify API}
  gem.homepage = "http://github.com/Burgestrand/Hallon"
  gem.authors  = ["Kim Burgestrand"]
  gem.email    = 'kim@burgestrand.se'
  gem.license  = 'GNU AGPL'
  
  gem.description = IO.read('./README.markdown')
  gem.description = gem.description.force_encoding 'UTF-8' if gem.description.respond_to?(:force_encoding)
  
  # installation
  gem.extensions = FileList['ext/**/extconf.rb']
  gem.platform   = Gem::Platform::RUBY
  gem.version    = Hallon::Version::STRING
end.gemspec)

## -> with coverage
RSpec::Core::RakeTask.new('spec:rcov') do |spec|
  if RUBY_VERSION =~ /\A1\.9/
    spec.rspec_opts = '--require cover_me'
  else
    spec.rcov = true
  end
end

desc "Generates YARD documentation and open it."
task :doc => :yard do
  system 'open doc/index.html'
end

task :default => [:compile, :spec]