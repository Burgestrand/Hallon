# coding: utf-8
require 'hallon'
require './spec/support/config'

session = Hallon::Session.instance IO.read(ENV['HALLON_APPKEY']) do
  on(:log_message) do |message|
    puts "[LOG] #{message}"
  end
end

session.login ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD']
logged_in  = session.process_events_on(:logged_in) { |error| error }

unless logged_in == :ok
  abort "[ERROR] (:logged_in) #{Hallon::Error.explain(logged_in)}"
end

conn_error = session.process_events_on(:connection_error) do |error|
  session.logged_in? or error
end

unless conn_error == true
  abort "[ERROR] (:connection_error) #{Hallon::Error.explain(conn_error)}"
end

puts "Successfully logged in!"
