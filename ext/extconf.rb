require 'mkmf'

# For Mac OS if installed in /Library/Frameworks/libspotify.framework/
with_ldflags('-framework libspotify') { RUBY_PLATFORM.match 'darwin' }

# check for ruby!
unless have_header 'ruby.h'
  abort 'error: Missing ruby header'
end

# check for libspotify
unless have_func 'sp_session_init' or have_library 'spotify', 'sp_session_init'
  abort 'error: libspotify not installed'
end

# check for spotify API header
unless have_header 'libspotify/api.h' or have_header 'spotify/api.h'
  abort 'error: (lib)spotify/api.h missing'
end

# make sure we have thread support
unless have_library 'pthread', 'pthread_mutex_lock'
  abort 'error: missing posix thread-support'
end

create_makefile 'hallon' 