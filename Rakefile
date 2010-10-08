# coding: utf-8
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    # metadata
    gem.name     = 'hallon'
    gem.summary  = 'Delicious Ruby bindings for libspotify'
    gem.homepage = 'http://github.com/Burgestrand/Hallon'
    gem.author   = 'Kim Burgestrand'
    gem.email    = 'kim@burgestrand.se'
    gem.license  = 'GNU AGPL'

    gem.description = IO.read('./README.markdown')
    gem.description = gem.description.force_encoding 'UTF-8' if gem.description.respond_to?(:force_encoding)
    
    # dependencies
    gem.add_development_dependency "rspec", "~> 1.3.0"
  
    # installation
    gem.extensions    = %w(ext/extconf.rb)
    gem.files         = Dir['lib/*.rb']
  
    # documentation
    gem.extra_rdoc_files = %w(ext/hallon.c)
    gem.rdoc_options = ['--charset=UTF-8']
  
    # tests
    gem.test_files = Dir['spec/*.rb']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError => e
  puts "Jeweler (or a dependency) unavailable: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'doc'
  rdoc.title = "Hallon #{version}"
  rdoc.main  = 'README.markdown'
  rdoc.options << '--charset=UTF-8'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('ext/hallon.c')
end

namespace "ext" do
  task :mkmf do
    Dir.chdir('ext') do
      abort unless system('ruby extconf.rb')
    end
  end

  task :make do
    Dir.chdir('ext') do
      if File.exist?('Makefile')
        system('make')
      else
        puts "You must run ext:mkmf before ext:make"
      end
    end
  end

  task :clean do
    Dir.chdir('ext') do |path|
      system('make distclean')
    end
  end
  
  task :rebuild => ['ext:clean', 'ext:mkmf', 'ext:make']
end

desc "Builds Hallon from scratch and tests it"
task :build => ['ext:rebuild', 'spec']

task :spec => :check_dependencies
task :default => :spec