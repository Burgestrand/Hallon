require 'mkmf'

$CFLAGS << ' -O0 -ggdb -Wextra '

create_makefile 'libmockspotify', 'libmockspotify/src'
