# What’s this?
This is [Ruby](http://www.ruby-lang.org/en/) bindings for the official Spotify API. What this means is that you can use Ruby to interact with Spotify.

Hallon is inspired by [Greenstripes](http://github.com/sarnesjo/greenstripes), a similar library by [Jesper Särnesjö](http://jesper.sarnesjo.org/).

# How do I use it?
There are [installation instructions in the GitHub wiki for Hallon](http://wiki.github.com/Burgestrand/Hallon/installation-instructions). Once the installation is complete you can write code like this:

    # initiate connection
    session = Hallon::Session.instance IO.read('spotify_appkey.key')
    session.login username, password
    
    # fetch the playlist container
    playlists = session.playlists
    
    # add a new playlist to the container
    summer = playlists.add "Summer 2010"
    
    # Add awesome song by Thin Lizzy to beginning of playlist
    track = Hallon:Link.new("spotify:track:4yJmwG2C1SDgcBbV50xI91").to_obj
    summer.insert 0, track

    # logout
    session.logout

## This is awesome! I want to help!
Sweet! You contribute in more than one way!

### Write code!
[Fork Hallon](http://github.com/Burgestrand/Hallon/fork), [write tests for everything](http://rspec.info/) you do (so I don’t break anything you did during my own development) and send a pull request.

You can see a list of functions that I have, and have not, used in Hallon in the [coverage document](http://github.com/Burgestrand/Hallon/blob/master/COVERAGE.markdown).

### [Send me feedback and requests](http://github.com/Burgestrand/Hallon/issues)
Really, I ❤ feedback! Suggestions on how to improve the API, tell me what is delicious about Hallon, tell me what is yucky about Hallon… anything! All feedback is useful in one way or another.

You can reach me either through [Hallons issue tracker](http://github.com/Burgestrand/Hallon/issues), [GitHub messaging system](http://github.com/inbox/new/Burgestrand) or you can find [my e-mail listed on my GitHub profile](http://github.com/Burgestrand).

## What’s the catch?
There are several!

### Hallon is unstable
I’ve never developed anything in C before, and I’ve been using Ruby for about a month. With that said, Hallon should be considered experimental.

### Hallon only supports one session per process
You can only keep one session with Spotify alive at a time in the same process, due to a limitation of `libspotify`.

### Hallon is licensed under GNU AGPL
Hallon is licensed under the [GNU AGPL](http://www.gnu.org/licenses/agpl-3.0.html), which is a very viral license. In summary, anything that is using Hallon in any way must also be open sourced (and source must be available for its’ users) under the GNU AGPL. I will most likely change the license to the X11 license or something similar in the future. This license can always be lifted and if you talk to me personally we could work something out. :)