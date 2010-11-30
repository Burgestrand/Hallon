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

## Jeweler
jeweler_task = Jeweler::Tasks.new do |gem|
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
end
Jeweler::RubygemsDotOrgTasks.new

## rake-compiler
gemspec = jeweler_task.gemspec
# gemspec.version = jeweler_task.jeweler.version
Rake::ExtensionTask.new('hallon', gemspec)

## RSpec
rspec_opts = '-Ilib -Ispec -rspec_helper'
RSpec::Core::RakeTask.new do |spec|
  spec.rspec_opts = rspec_opts
end

## -> with coverage
RSpec::Core::RakeTask.new('spec:rcov') do |spec|
  if RUBY_VERSION =~ /\A1\.9/
    spec.rspec_opts = [rspec_opts, '--require cover_me'].join(' ')
  else
    spec.rcov = true
  end
end

## YARD
YARD::Rake::YardocTask.new

task :default => :spec