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
end

desc "Process the Hallon codebase, finding out which Spotify methods are being used"
task 'spotify:coverage' do
  require 'bundler/setup'

  require 'pry'
  require 'set'

  module Spotify
    # Wrapped functions return pointers that are auto-GC’d by Ruby,
    # so we ignore add_ref and release for these methods; but since
    # we don’t know their type by mere name, we must resort to this
    # hack to do it automatically (because we can).
    class << self
      def lookup_return_value(name)
        @function_to_return_type[name.to_s]
      end

      def define_singleton_method(name, &block)
        return_type = block.binding.eval <<-CODE
          begin
            return_type if __method__ == :wrap_function
          rescue NameError
            nil
          end
        CODE

        if return_type
          @function_to_return_type ||= {}
          @function_to_return_type[name.to_s] = return_type
        end

        super
      end
    end
  end

  require 'spotify'

  begin
    require 'ruby_parser'
  rescue LoadError
    puts "You need ruby_parser for the spotify:coverage rake task"
    abort
  end

  methods = Spotify.methods(false).map(&:to_s)
  auto_gc = Set.new(methods.grep(/!\z/).select { |m| Spotify.lookup_return_value(m) })
  auto_err = Set.new(methods.grep(/!\z/)).difference(auto_gc)
  covered = Set.new(methods)
  warning = []
  ignored = [
    'attach_function',  # spotify overloads this
    'session_release',  # segfaults on libspotify <= 9
    'session_userdata', # wont support this
    'error_message',    # supported by Hallon::Error.explain
    'link_as_track',    # using link_as_track_and_offset instead
    'link_as_track!',   # using link_as_track_and_offset! instead
    'wrap_function',    # not a spotify function
    'lookup_return_value', # custom method
    'define_singleton_method', # overloaded by us
  ]

  covered -= ignored

  # Handlers for different AST nodes
  printer  = proc { |*args| p args }
  silencer = proc { }
  handlers = Hash.new(Hash.new(silencer))

  # Direct calls
  handlers[Sexp.new(:const, :Spotify)] = Hash.new(proc do |_, meth, _|
    if auto_gc.include?("#{meth}!")
      warning << [$file, meth]
    end

    result = [meth]

    auto_err_lookup = meth.to_s.delete('!') + '!' # just one !

    # if it has auto-error, we account for both versions, just assume
    # we are doing the right thing here
    if auto_err.member?(auto_err_lookup)
      result << auto_err_lookup
      result << auto_err_lookup.delete('!')
      result.uniq!
    end

    if meth =~ /(.+)!\z/
      # if it’s auto-GC’d, we can also account for _release and _add_ref
      if (return_type = Spotify.lookup_return_value(meth))
        result << $1
        result << "#{return_type}_release"
        result << "#{return_type}_add_ref"
        result << "#{return_type}_release!"
        result << "#{return_type}_add_ref!"
      end
    end

    result
  end)

  # DSL Methods
  no_receiver = handlers[nil] = Hash.new(silencer)
  no_receiver[:from_link] = no_receiver[:to_link] = proc do |recv, meth, (_, name)|
    prefix = meth == :to_link ? "link_create" : "link"
    method = "%s_%s" % [prefix, name]
    [method, "#{method}!"]
  end

  # Hallon::Enumerator
  no_receiver[:size] = proc do |recv, meth, (_, name)|
    name
  end

  # Hallon::Enumerator
  no_receiver[:item] = proc do |recv, meth, (_, name)|
    method = name.to_s
    [method.delete("!"), method]
  end

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

  unless warning.empty?
    puts "Warnings (use auto-gc methods instead!):"
    warning.each do |file, method|
      puts "  #{file}: #{method}"
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
