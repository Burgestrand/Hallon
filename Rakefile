# coding: utf-8
require 'rake'

begin
  require 'bundler'
  Bundler::GemHelper.install_tasks
rescue LoadError
  # not everybody needs these
end

require 'yard'
YARD::Rake::YardocTask.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new('spec') do |task|
  task.ruby_opts = '-W2'
  task.rspec_opts = '-rsimplecov'

  # rspec does not do this for us if we specify rspec_opts
  opts_file   = File.expand_path('.rspec', File.dirname(__FILE__))
  opts_string = File.readlines(opts_file).map(&:rstrip).join(' ')
  task.rspec_opts += ' ' + opts_string
end

desc "Start a console with Hallon loaded (no other setup is done)"
task :console do
  exec 'pry -Ilib -rhallon'
end

desc "Process the Hallon codebase, finding out which Spotify methods are being used"
task 'spotify:coverage' do
  require 'bundler/setup'

  require 'pry'
  require 'set'
  require 'spotify'

  begin
    require 'ruby_parser'
  rescue LoadError
    puts "You need ruby_parser for the spotify:coverage rake task"
    abort
  end

  methods = Spotify.methods(false).map(&:to_s).reject { |x| x =~ /_add_ref|_release/ }
  covered = Set.new(methods)
  auto_error = Set.new(methods.select { |x| x =~ /!/ })
  inexisting = []
  ignored = [
    'attach_function',  # spotify overloads this
    'session_release',  # segfaults on libspotify <= 9, and sometimes deadlocks on libspotify <= v12
    'session_userdata', # wont support this
    'build_id',         # no use for it
    'platform',         # not necessary yet
    'mac?',             # has no use for it
    'search_playlist',  # does not GC convention, dangerous to use!
    'error_message',    # supported by Hallon::Error.explain
    'link_as_track',    # using link_as_track_and_offset instead
    'wrap_function',    # not a spotify function
    'lookup_return_value', # custom method
    'define_singleton_method', # overloaded by us
  ]

  covered -= ignored

  # Handlers for different AST nodes
  printer  = proc { |*args| p args }
  silencer = proc { }
  dsl_method = proc { |recv, meth, (_, name)| name }
  handlers = Hash.new(Hash.new(silencer))

  # Direct calls
  handlers[Sexp.new(:const, :Spotify)] = Hash.new(proc do |_, meth, _|
    meth &&= meth.to_s

    [meth].tap do |result|
      if meth =~ /!/ && auto_error.include?(meth)
        result << meth.delete("!")
      else
        result << "#{meth}!"
      end

      inexisting << meth unless Spotify.respond_to?(meth)
    end
  end)

  # DSL Methods
  no_receiver = handlers[nil] = Hash.new(silencer)
  no_receiver[:from_link] = no_receiver[:to_link] = proc do |recv, meth, (_, name)|
    prefix = meth == :to_link ? "link_create" : "link"
    "%s_%s" % [prefix, name]
  end

  # Hallon::Enumerator
  no_receiver[:size] = dsl_method

  # Hallon::Enumerator
  no_receiver[:item] = dsl_method

  fails = {}
  FileList['lib/**/*.rb'].each do |file|
    begin
      $file = file
      klass = defined?(Ruby19Parser)? Ruby19Parser : RubyParser
      ast = klass.new.parse File.read(file)
      ast.each_of_type(:call) do |_, recv, meth, args, *rest|
        name = handlers[recv][meth].call(recv, meth, args)
        covered.subtract Array(name).map(&:to_s)
      end
    rescue => e
      fails[file] = e.message.strip + " (#{e.class.name} #{e.backtrace[0..3]})"
    end
  end

  covered.group_by { |m| m[/[^_]+/] }.each_pair do |group, methods|
    puts "#{group.capitalize}:"
    no_bangs = methods.map(&:to_s).map { |m| m.delete('!') }.uniq
    no_bangs.each do |m|
      puts "  #{m}"
    end
    puts
  end

  puts "Ignored:"
  ignored.each_slice(3) do |slice|
    puts "  #{slice.join(', ')}"
  end
  puts

  unless fails.empty?
    puts "Failures:"
    fails.each_pair do |file, fail|
      puts "  #{file}: #{fail}"
    end
    puts
  end

  unless inexisting.empty?
    puts "Non-existing methods (but used; remove!):"
    inexisting.each do |fail|
      puts "  #{fail}"
    end
    puts
  end

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
