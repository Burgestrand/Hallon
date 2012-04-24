#!/usr/bin/env ruby

if ARGF.file == STDIN
  puts "You forgot to give me a file!"
  abort "Usage: ruby application_key_converter.rb spotify_appkey.key > new_spotify_appkey.key"
end

old_format = ARGF.read.split.join
new_format = [old_format].pack("H*")

print new_format
