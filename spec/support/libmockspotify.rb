# Where is libmockspotify located?
$mock_root = File.expand_path('../../libmockspotify', __FILE__)

# Make sure we’ve compiled latest version
Dir.chdir($mock_root) { `rake compile` }

# Now, overload FFI so we can circumvent libspotify-ruby
require 'ffi'

module FFI
  module Library
    alias_method :_ffi_lib, :ffi_lib
    def ffi_lib(*libs)
      _ffi_lib %w(so bundle dylib).map { |ext| "%s/libspotify.%s" % [$mock_root, ext] }
    end

    alias_method :_attach_function, :attach_function
    def attach_function(*args)
      _attach_function(*args)
    rescue FFI::NotFoundError => e
      warn "#{e.message}" if $VERBOSE
    end
  end
end
