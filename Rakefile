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

  begin
    require 'ruby_parser'
  rescue LoadError
    puts "You need ruby_parser for the spotify:coverage rake task"
    abort
  end

  methods = Spotify.methods(false).map(&:to_s)
  covered = Set.new(methods)
  ignored = [
    'session_release',  # segfaults on libspotify <= 9
    'session_userdata', # wont support this
    'link_as_track',    # using link_as_track_and_offset instead
    'toplistbrowse_add_ref', # toplistbrowse creates its’ own pointer
    'artistbrowse_add_ref',  # artistbrowse creates its’ own pointer
    'albumbrowse_add_ref',   # albumbrowse creates its’ own pointer
    'link_add_ref',          # all creation of links has +1 ref
    'image_add_ref',         # all creation of image has +1 ref
    'search_add_ref',        # search creates its’ own pointer
  ]

  covered -= ignored

  # Handlers for different AST nodes
  printer  = proc { |*args| p args }
  silencer = proc { }
  handlers = Hash.new(Hash.new(silencer))

  # Direct calls
  handlers[Sexp.new(:const, :Spotify)] = Hash.new(proc { |_, meth, _| meth })

  # Spotify Pointer
  pointer = handlers[Sexp.new(:colon2, [:const, :Spotify], :Pointer)] = Hash.new(printer)
  pointer[:new] = proc do |recv, meth, (_, ptr, name, release)|
    name = name.value
    release &&= release.value != :false
    ["#{name}_release", "#{name if release}_add_ref"]
  end

  # DSL Methods
  no_receiver = handlers[nil] = Hash.new(silencer)
  no_receiver[:from_link] = no_receiver[:to_link] = proc do |recv, meth, (_, name)|
    prefix = meth == :to_link ? "link_create" : "link"
    "%s_%s" % [prefix, name.value]
  end

  FileList['lib/**/*.rb'].each do |file|
    ast   = RubyParser.new.parse File.read(file)
    ast.each_of_type(:call) do |_, recv, meth, args, *rest|
      name = handlers[recv][meth].call(recv, meth, args)
      covered.subtract Array(name).map(&:to_s)
    end
  end

  covered.group_by { |m| m[/[^_]+/] }.each_pair do |group, methods|
    puts "#{group.capitalize}:"
    methods.each do |m|
      puts "  #{m}"
    end
    puts
  end

  puts "Ignored:"
  ignored.each_slice(3) do |slice|
    puts "\t#{slice.join(', ')}"
  end
  puts

  puts "Coverage: %.02f%%" % (100 * (1 - covered.size.fdiv(methods.size)))
end

desc "Download mockspotify submodule"
task 'mock:fetch' do
  unless File.exists?('./spec/mockspotify/libmockspotify/src/libmockspotify.h')
    sh 'git submodule update --init'
  end
end

desc "Compile mockspotify"
task 'mock:compile' => 'mock:fetch' do
  Dir.chdir 'spec/mockspotify' do
    sh 'ruby extconf.rb'
    sh 'make'
  end
end

task :spec => 'mock:compile'
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
  print "Do you really want to delete all non-git tracked files? (y/n) [n]: "
  if STDIN.gets.chomp == 'y'
    sh 'git clean -fdx --exclude Gemfile.lock --exclude spec/support/config.rb'
  else
    puts "Whew. Close one!"
  end
end

task :default => [:spec]
