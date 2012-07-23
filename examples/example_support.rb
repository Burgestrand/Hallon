# coding: utf-8

# Hello there, and welcome!
#
# My name is example_support.rb, and I shall be your loyal servant. What you see here
# is all my offerings I have for today. Of course, I shall gladly point out to you what
# each and every one of these offers bring you.
#
# If at any point you feel lost, do not hesitate to consult with my superiors. You may
# find them at https://github.com/Burgestrand/Hallon. Thank you!

$stdout.sync = true

# First, I need the power to ask you questions. You need not care much about this particular
# piece of me; only keep in mind that it should help keep the rest of me less cluttered.
def prompt(string, options = {})
  print(string + ': ')
  $stdout.flush
  system("stty -echo") if options[:hide]
  gets.chomp
ensure
  if options[:hide]
    system("stty echo")
    puts
  end
end

# Like before, this piece of me is not of much important. It is only to make sure you do
# not try to feed me propaganda. Move along.
def prompt_link(string)
  loop do
    uri = prompt(string)
    if uri.empty?
      break
    elsif Hallon::Link.valid?(uri)
      break uri
    else
      puts "Please enter a valid Spotify URI (or just enter to quit)."
    end
  end
end

# Making sure you receive the latest of the latest. Hallon does not wish to
# be replaced by older versions when showing you the shiny.
$LOAD_PATH.unshift(File.expand_path('../lib', File.dirname(__FILE__)))
require 'hallon'

# This is a quick sanity check, to make sure we have all the necessities in order.
appkey_path = File.expand_path('./spotify_appkey.key')
unless File.exists?(appkey_path)
  abort <<-ERROR
    Your Spotify application key could not be found at the path:
      #{appkey_path}

    Please adjust the path in examples/common.rb or put your application key in:
      #{appkey_path}

    You may download your application key from:
      https://developer.spotify.com/en/libspotify/application-key/
  ERROR
end

# And now, before I ask you for your jewels, I shall instill within you a sense of
# belonging and comfort. This is in order to make you less surprised about my rude
# questions.
puts "Hallon’s interactive examples run live against Spotify, and as such
they require actual login credentials before they may run."

# Spotify requires a rite of passage. It’s own variant of “open sesame”, so we will
# ask you to provide them with your information.
hallon_username = prompt("Please enter your spotify username")
hallon_password = prompt("Please enter your spotify password", hide: true)
hallon_appkey   = IO.read(appkey_path)

# Make sure the credentials are there. We don’t want to go without them.
if hallon_username.empty? or hallon_password.empty?
  abort <<-ERROR
    Sorry, you must supply both username and password for Hallon to be able to log in.

    You may also edit examples/common.rb by setting your username and password directly.
  ERROR
end

# Finally, we log in, making sure we show you just about everything Spotify tells us
# for the entire coming session.
session = Hallon::Session.initialize(hallon_appkey) do
  on(:log_message) do |message|
    puts "[LOG] #{message}"
  end

  on(:credentials_blob_updated) do |blob|
    puts "[BLOB] #{blob}"
  end

  on(:connection_error) do |error|
    Hallon::Error.maybe_raise(error)
  end

  on(:logged_out) do
    abort "[FAIL] Logged out!"
  end
end
session.login!(hallon_username, hallon_password)

puts "Successfully logged in!"
# that is all for me. Thank you, I will see you again!
