# coding: utf-8
require 'hallon'
require './spec/support/config'

session = Hallon::Session.initialize IO.read(ENV['HALLON_APPKEY']) do
  on(:log_message) do |message|
    puts "[LOG] #{message}"
  end
end

session.login ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD']

session.wait_for(:logged_in) { |error| Hallon::Error.maybe_raise(error) }
session.wait_for(:connection_error) do |error|
  session.logged_in? or Hallon::Error.maybe_raise(error)
end

puts "Successfully logged in!"
