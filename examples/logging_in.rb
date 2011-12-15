# coding: utf-8

$LOAD_PATH.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'hallon'
require './spec/support/config'

session = Hallon::Session.initialize IO.read(ENV['HALLON_APPKEY']) do
  on(:log_message) do |message|
    puts "[LOG] #{message}"
  end
end

session.login!(ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD'])

puts "Successfully logged in!"
