# coding: utf-8
require 'rake'

require 'bundler'
Bundler::GemHelper.install_tasks

require 'yard'
YARD::Rake::YardocTask.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new('spec') do |task|
  task.skip_bundler = true
  task.ruby_opts = '-W2'
end

desc "Run the full test suite and generate a coverage report"
task 'spec:cov' => ['clean', 'spec'] do
  require 'cover_me'
  require './spec/support/cover_me'

  CoverMe.config.at_exit = proc { `open coverage/index.html` }
  CoverMe.complete!
end

desc "Process the Hallon codebase, finding out which Spotify methods are being used"
task 'spotify:coverage' do
  require 'set'
  require 'spotify'

  dynamicly_used = []
  dynamicly_used << "link_create_from_track" # lib/hallon/track.rb
  dynamicly_used << "track_add_ref"          # lib/ext/spotify.rb
  dynamicly_used << "track_release"          # lib/ext/spotify.rb
  dynamicly_used << "link_create_from_image" # lib/hallon/image.rb
  dynamicly_used << "image_release"          # lib/ext/spotify.rb
  dynamicly_used << "link_create_from_user"  # lib/hallon/user.rb
  dynamicly_used << "user_add_ref"           # lib/ext/spotify.rb
  dynamicly_used << "user_release"           # lib/ext/spotify.rb
  dynamicly_used << "link_as_track"          # IGNORE
  dynamicly_used << "link_release"           # lib/ext/spotify.rb

  methods = Spotify.methods(false).map(&:to_s) - dynamicly_used
  covered = Set.new(methods)
  matcher = /Spotify(?:::|\.)([\w_]+)[ \(]/

  FileList['lib/**/*.rb'].each do |file|
    File.read(file).scan(matcher) { |method, _| covered.delete(method) }
  end

  covered.group_by { |m| m[/[^_]+/] }.each_pair do |group, methods|
    puts "#{group.capitalize}:"
    methods.each do |m|
      puts "  #{m}"
    end
    puts
  end

  puts "Coverage: %.02f%%" % (100 * (1 - covered.size.fdiv(methods.size)))
end

task :test => :spec

#
# Custom tasks
#
desc "Generates YARD documentation and open it."
task :doc => :yard do
  sh 'open doc/index.html'
end

desc "Remove generated files"
task :clean do
  sh 'git clean -fdx --exclude Gemfile.lock --exclude spec/support/config.rb'
end

task :default => [:spec]
