# coding: utf-8
require 'rake'

require 'bundler'
Bundler::GemHelper.install_tasks

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

desc "Start watchr, open a new tab and open Hallon directory in $EDITOR using terminitor"
task(:work) { system 'terminitor start' }

task :default => [:spec]