# coding: utf-8

$LOAD_PATH.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'hallon'
require './spec/support/config'

# Utility
def prompt(str)
  print str
  gets.chomp
end

# Hallon
session = Hallon::Session.initialize IO.read(ENV['HALLON_APPKEY']) do
  on(:log_message) do |message|
    $stderr.puts "[LOG] #{message}"
  end
end

while url = prompt("Enter a Spotify URI: ")
  begin
    p (link = Hallon::Link.new(url))
    puts "\tHTTP URL: #{link.to_url}"
    puts "\tSpotify URI: #{link.to_str}"
    puts "\tLink type: #{link.type}"
  rescue ArgumentError => e
    puts e
  end
end
