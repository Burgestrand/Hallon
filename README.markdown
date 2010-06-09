# What’s this?
This is [Ruby](http://www.ruby-lang.org/en/) bindings for the official Spotify API. What this means is that you can use Ruby to interact with Spotify.

Hallon is inspired by [Greenstripes](http://github.com/sarnesjo/greenstripes), a similar library by [Jesper Särnesjö](http://jesper.sarnesjo.org/).

# … why?
I need a library to interface with Spotify for another project that I’ve named “restify” — which is a HTTP REST gateway to the Spotify API, used internally for yet another project.

# How do I use it?
`libspotify` itself needs a [Spotify premium account](https://www.spotify.com/se/get-spotify/premium/), and subsequently an application key. If you have both, follow these steps:

- download and install `libspotify`
- download Hallon: `git clone git://github.com/Burgestrand/Hallon.git; cd Hallon`
- install the dependencies using Bundler `bundle install`
- build the extension and test it: `rake build`
- build the gem and install it `rake gem; gem install Hallon-*.gem`

For a list of available commands use `rake -T`.

## How do I install `libspotify`?
Installing `libspotify` means you need to put the binary library and the headers on a location where GCC can find them. First of all, [download the library](https://developer.spotify.com/en/libspotify/overview/)

### … on Mac OS?
Copy the `libspotify.framework` folder to `/Library/Frameworks/libspotify.framework`, Hallon handles the rest. :)

## This is awesome! I want to help!
Sweet! You can do this in several ways!

- You can give me money! I know, I know. Money is not sexy. However! Even such a small amount as $1 will most likely make me very happy (and sexy!), which increases the chances of me putting more hours on Hallon. There is a tiny we button up in the corner on this projects’ GitHub page which sends me money via paypal.
- Write code! Just fork Hallon, write tests for everything you do (so I don’t break anything you did during my own development) and send a pull request.
- Send me feedback! Really, I ❤ feedback! Suggestions on how to improve the API, tell me what is delicious about Hallon, tell me what is yucky about Hallon… anything! All feedback is useful in one way or another.

## What’s the catch?
There are several!

### Hallon is unstable
I’ve never developed anything in C before, and I’ve been using Ruby for about a month. With that said, Hallon should be considered experimental.

### Hallon only supports one session per process
You can only keep one session with Spotify alive at a time in the same process, due to a limitation of `libspotify`.

### Hallon is licensed under GNU AGPL
Hallon is licensed under the [GNU AGPL](http://www.gnu.org/licenses/agpl-3.0.html), which is a very viral license. In summary, anything that is using Hallon in any way must also be open sourced (and source must be available for its’ users) under the GNU AGPL. I will most likely change the license to the X11 license or something similar in the future.

## Usage

    # initiate connection
    session = Hallon::Session.instance IO.read('spotify_appkey.key')
    session.login username, password
    
    # fetch the playlist container
    playlists = session.playlists
    
    # add a new playlist to the container
    summer = playlists.add "Summer 2010"
    
    # Add awesome song by Thin Lizzy
    track = Link.new("spotify:track:4yJmwG2C1SDgcBbV50xI91").to_obj
    summer.push track

    # logout
    session.logout

## Notes of interest for developers
- Playlists take some time to be acknowledged by the server (up to a minute), but they can still be operated on. The real issue is that we don’t want to let the application close until the playlist has been fully been synched.
  Further discussion in the Spotify IRC shows that logging out before the application is allowed to exit remedies this issue. Now, what to do about disconnects?
- I would like to split hallon.c into several files, to make it more manageable. Problem right now is that the library is quite tightly coupled.
- You’ve had some issues with the Spotify callback functions, as they are executed in another thread than the current one and are only passed the pointer to the `sp_session`. Your attempt to put the `sp_session` and `Session` object in a linked list and then use lookups to notify the actual object have some very unexpected behavior and thread inconsistencies. It works, but badly. Do not try it again! D: