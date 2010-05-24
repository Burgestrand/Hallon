require 'rake'

begin
  require 'rspec/core/rake_task'
  
  desc "Runs all tests"
  task :test do
    system 'rspec -fd spec/**'
  end
  
  task :default => :test
rescue LoadError
  $stderr.puts 'WARNING: rspec2 missing, cannot run test suite'
  task :default => :build
end

namespace "ext" do
  task :mkmf do
    Dir.chdir('ext') do
      system('ruby extconf.rb')
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
      puts "Cleaning ext/ folder..."
      ['Makefile', 'Hallon.bundle', 'mkmf.log', 'hallon.o'].each do |file|
        File.unlink file rescue next
      end
    end
  end
  
  task :rebuild => ['ext:clean', 'ext:mkmf', 'ext:make']
end

desc "Builds Hallon from scratch and tests it"
task :build => ['ext:rebuild', 'test']

desc "Creates the Gem"
task :gem do
  system('gem build Hallon.gemspec')
end

desc "Generates rdoc documentation in doc/"
task :doc do
  FileUtils.rmtree 'doc/'
  system('rdoc -c utf-8 -H -x Rakefile -x Makefile')
end