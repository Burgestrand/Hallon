# coding: utf-8
require 'rake'

require 'bundler'
Bundler::GemHelper.install_tasks

require 'yard'
YARD::Rake::YardocTask.new

require 'rspec/core/rake_task'
desc "Run all specs (even those requiring logging in to Spotify)"
RSpec::Core::RakeTask.new('spec:full')
RSpec::Core::RakeTask.new('spec') do |task|
  task.pattern = 'spec/hallon/*_spec.rb'
  task.rspec_opts = '--tag ~logged_in'
end

desc "Run the full test suite and generate a coverage report"
task 'spec:cov' => 'spec:full' do
  require 'cover_me'
  CoverMe.complete!
end

task :test => :spec

#
# Custom tasks
#
desc "Generates YARD documentation and open it."
task :doc => :yard do
  system 'open doc/index.html'
end

task :default => [:spec]
