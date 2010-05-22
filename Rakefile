require 'rake'

begin
  require 'rspec/core/rake_task'
  
  desc "Runs all tests and outputs errors on STDERR"
  Rspec::Core::RakeTask.new :test do |task|
    task.fail_on_error = false
    task.pattern = 'spec/**'
  end
  
  task :default => :test
rescue LoadError
  $stderr.puts 'rspec missing: tests are unavailable'
end