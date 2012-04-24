#!/usr/bin/env ruby

require 'pry'

if ARGF.file == STDIN
  puts "You forgot to give me a file!"
  abort "Usage: ruby application_key_converter.rb spotify_appkey.key > new_spotify_appkey.key"
end

new_format = "".force_encoding('BINARY')
old_format = ARGF.read.split.join

old_format.each_char.each_slice(2) do |(high, low)|
  hex = high << low
  new_format << hex.to_i(16).chr
end

print new_format
