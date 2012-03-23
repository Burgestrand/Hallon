# Some helper methods that we’ll use throughout the examples.
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

# Make sure we load the Hallon from lib/ and not system gems.
$LOAD_PATH.unshift(File.expand_path('../lib', File.dirname(__FILE__)))
require 'hallon'

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

# Ask the user running the examples for their spotify credentials.
hallon_username = prompt("Please enter your spotify username")
hallon_password = prompt("Please enter your spotify password", hide: true)
hallon_appkey   = IO.read(appkey_path)

# Make sure the credentials are there.
if hallon_username.empty? or hallon_password.empty?
  abort <<-ERROR
    Sorry, you must supply both username and password for Hallon to be able to log in.

    You may also edit examples/common.rb by setting your username and password directly.
  ERROR
end

# Finally, we log in!
session = Hallon::Session.initialize(hallon_appkey) do
  on(:log_message) do |message|
    puts "[LOG] #{message}"
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
