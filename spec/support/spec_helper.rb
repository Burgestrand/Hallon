require 'hallon'

# Supply the following:
# APPKEY: IO.read 'path/to/spotify_appkey.key'
# USERNAME: 
# PASSWORD: 
require File.expand_path('../config', __FILE__)

TRACK_URI    = "spotify:track:5CwHu4IDP6MYCrSg6xyVPa"
TRACK_URI2   = "spotify:track:5st5644IlBmKiiRE73UsoZ"
PLAYLIST_URI = "spotify:user:burgestrand:playlist:4MsjQL7fkrtfWAOyV5Rnwa"
PLAYLIST     = "rspec-" + Time.now.gmtime.strftime("%Y-%m-%d %H:%M:%S.#{Time.now.gmtime.usec}")

# Have to do this, all operations require a valid instance
INSTANCE = Hallon::Session.instance APPKEY