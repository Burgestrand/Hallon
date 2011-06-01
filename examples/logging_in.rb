# coding: utf-8
require 'hallon'
require './spec/support/config'

session = Hallon::Session.instance IO.read(ENV['HALLON_APPKEY']) do
  on(:logged_in) do |error|
    puts "logged_in callback: #{error}"
  end
end

notify = session.new_cond

session.protecting_handlers do
  session.synchronize do
    session.on(:notify_main_thread) do
      session.synchronize { notify.signal }
    end

    session.on(:logged_in) do |error|
      session.synchronize do
        login_error = error
        notify.signal
      end
    end

    session.login ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD']
    notify.wait_until do
      session.process_events
      session.logged_in?
    end
  end
end

if session.logged_in?
  puts "YAY! We’ve logged in!"
else
  puts "Boo. We didn’t log in: #{login_error}"
end
