require 'rake'

begin
  require 'rspec/core/rake_task'
  
  desc "Runs all tests"
  Rspec::Core::RakeTask.new :test do |task|
    task.fail_on_error = false
    task.pattern = 'spec/**'
  end
  
  task :default => :test
rescue LoadError
  $stderr.puts 'rspec missing: tests are unavailable'
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
end


desc "Builds Hallon from scratch"
task :build => ['ext:clean', 'ext:mkmf', 'ext:make']