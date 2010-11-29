What is Hallon?
===============
Hallon provides [Ruby][] bindings for [libspotify][], the official Spotify C API. This allows you to use an awesome language to interact with an awesome service.

Hallon is inspired by [Greenstripes][], a similar library by [Jesper Särnesjö][].

How do I use it?
-----------------
There are [installation instructions in the GitHub wiki for Hallon](http://wiki.github.com/Burgestrand/Hallon/installation-instructions). Once the installation is complete you can write code like this:

    session = Hallon::Session.new IO.read('spotify_appkey.key')
    session.login username, password do |session|
      # playlists = private method of session instance
      summer2010 = playlists.add("Summer 2010").wait
      
      # @param #to_track
      # @return Playlist
      summer2010.push "spotify:track:4yJmwG2C1SDgcBbV50xI91"
    end # calls logout

This is awesome! I want to help!
--------------------------------
Sweet! You contribute in more than one way!

### Write code!
[Fork Hallon](http://github.com/Burgestrand/Hallon), [write tests for everything](http://relishapp.com/rspec) you do (so I don’t break your stuff during my own development) and send a pull request. If you modify existing files, please adhere to the coding standard surrounding your code!

### [Send me feedback and requests](http://github.com/Burgestrand/Hallon/issues)
Really, I ❤ feedback! Suggestions on how to improve the API, tell me what is delicious about Hallon, tell me what is yucky about Hallon… anything! All feedback is useful in one way or another.

You can reach me either through [Hallons issue tracker](http://github.com/Burgestrand/Hallon/issues), [GitHub messaging system](http://github.com/inbox/new/Burgestrand) or you can find [my e-mail listed on my GitHub profile](http://github.com/Burgestrand).

## What’s the catch?
There are several!

### Hallon is unstable
This is *the only* project I’ve ever used C for. With that said, Hallon should be considered extremely experimental.

### Hallon only supports one session per process
You can only keep one session with Spotify alive at a time in the same process, due to a limitation of `libspotify`.

### Hallon is licensed under GNU AGPL
Hallon is licensed under the [GNU AGPL](http://www.gnu.org/licenses/agpl-3.0.html), which is a very special license:
> If you are releasing your program under the GNU AGPL, and it can interact with users over a network, the program should offer its source to those users in some way. For example, if your program is a web application, its interface could display a “Source” link that leads users to an archive of the code. The GNU AGPL is flexible enough that you can choose a method that's suitable for your specific program—see section 13 for details.

The license is likely to change to the X11 license sometime under 2011. If the AGPL license makes trouble for you, contact me and I’ll most likely give you an exception. :)

[Ruby]: http://www.ruby-lang.org/en/
[libspotify]: http://developer.spotify.com/en/libspotify/overview/
[Greenstripes]: http://github.com/sarnesjo/greenstripes
[Jesper Särnesjö]: http://jesper.sarnesjo.org/