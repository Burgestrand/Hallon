# coding: utf-8
require 'hallon'
require './spec/support/config'

session = Hallon::Session.instance IO.read(ENV['HALLON_APPKEY']) do
  on(:log_message) do |message|
    puts "[LOG] #{message}"
  end
end

session.login ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD']

session.process_events_on(:logged_in) { |error| Hallon::Error.maybe_raise(error) }
session.process_events_on(:connection_error) do |error|
  session.logged_in? or Hallon::Error.maybe_raise(error)
end

puts "Successfully logged in!"
