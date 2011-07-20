# Overload FFI so we can circumvent libspotify-ruby
require 'ffi'
require 'mockspotify'

module FFI
  module Library
    alias_method :_ffi_lib, :ffi_lib
    def ffi_lib(*libs)
      _ffi_lib MockSpotify.lib_path
    end

    alias_method :_attach_function, :attach_function
    def attach_function(*args)
      _attach_function(*args)
    rescue FFI::NotFoundError => e
      warn "#{e.message}" if $VERBOSE
    end
  end
end
