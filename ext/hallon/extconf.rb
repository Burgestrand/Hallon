require 'mkmf'

def error(message)
  abort "[ERROR] #{message}"
end

# For Mac OS if installed in /Library/Frameworks/libspotify.framework/
with_ldflags('-framework libspotify') { RUBY_PLATFORM.match 'darwin' }

# check for ruby!
error 'Missing ruby header' unless have_header 'ruby.h'
error 'Hallon requires ruby ~> 1.9' unless RUBY_VERSION =~ /\A1\.9/

# check for libspotify
unless have_func 'sp_session_release' or have_library 'spotify', 'sp_session_release'
  error 'libspotify not installed'
end

# check for spotify API header
unless have_header 'libspotify/api.h' or have_header 'spotify/api.h'
  error '(lib)spotify/api.h missing'
end

# make sure we have pthread support
unless have_library 'pthread', 'pthread_mutex_lock'
  error 'missing posix thread-support'
end

with_cflags('-pipe -ggdb -O0 -Wall') { ENV['DEBUG'] }
create_makefile 'hallon'