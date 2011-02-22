#
# Signals
# 
Signal.trap('INT') do
  Process.exit(true)
end

#
# Helpers
# 

# Takes a filename and returns the rspec file associated to it.
# 
# @note Does not check for file existence.
# @param [String]
# @return [String]
def spec_for(filename)
  name = Pathname.new(filename).basename.to_s
  spec = Pathname.new('spec/hallon')
  spec += name.gsub(/\.(rb|c|h)\Z/, '') << '_spec.rb'
  spec.to_s
end

# Holder for scheduled “to run” specs
pending_specs = Array.new

#
# Commands
# 
define_singleton_method(:rspec) do |*args|
  args = Dir['spec/**/*_spec.rb'].to_a if args[0] == :all
  pending_specs -= args
  system('bundle', 'exec', 'rspec', *args)
end

#
# Watchr specific!
#
scripts = Watchr::Script.new
scripts.watch(File.basename(__FILE__)) { reload }

# C changes:
scripts.watch('ext/.*\.(c|h)')  { |md| pending_specs << spec_for(md[0]) }
scripts.watch('hallon\.bundle') { rspec pending_specs }

# Ruby changes:
scripts.watch('lib/.*\.rb') { |md| rspec spec_for(md[0]) }

# RSpec changes:
scripts.watch('spec/.*_spec\.rb') { |md| rspec md[0] }
scripts.watch('spec_helper\.rb')  { rspec :all }

Watchr::Controller.new(scripts, Watchr.handler.new).run