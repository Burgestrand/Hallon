require 'mkmf'

def error(message)
  abort "[ERROR] #{message}"
end

error 'Missing ruby header' unless have_header 'ruby.h'
error 'Hallon requires ruby ~> 1.9' unless RUBY_VERSION =~ /\A1\.9/

dir_config 'libspotify'
checking_for 'libspotify' do
  with_ldflags('-framework libspotify') do
    try_link 'int main(void) { return 0; }'
  end unless have_library 'spotify'
  
  have_func 'sp_session_create', 'libspotify/api.h'
end or error 'libspotify not installed'

# make sure we have pthread support
unless have_library 'pthread', 'pthread_mutex_lock'
  error 'missing posix thread-support'
end

with_cflags('-pipe -ggdb -O0 -Wall') { ! ENV['DEBUG'] }
create_makefile 'hallon'