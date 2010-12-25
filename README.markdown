Note about 1.0.0 branch
=======================
I’ve decided to restructure Hallon, but I’ll do it as a way of rebuilding it. This is the first major rewrite since release, and a much needed one. It’ll be easier for both me and external contributors to improve on Hallon, and that will hopefully pave the way for a 1.0.0 release.

This branch will be the main development branch from now and on.

Want to help? Look here!
------------------------
I am having troubles deciding how the API should work. This is a network library, and I need to handle connection errors, music delivery and metadata updates — all of which can happen concurrently.

This is what I want it to look like, kind of:

    session = Hallon::Session.new IO.read('spotify_appkey.key')
    session.login username, password
    
    playlist_container.each do |playlist|
      puts playlist.name
    end
    
    session.logout # called through an at_exit hook as well

For simplicity I want all operations that have an associated loading-callback to appear synchronous. This is done by making each of these blocking operations wait for the appropriate callback to be executed.

The main issue is disconnects: they might happen at any time, and may or may not be permanent errors. My current idea is that I’ll handle them using POSIX signals, but we’ll see how that goes when I tackle that problem.

---

What is Hallon?
===============
Hallon provides [Ruby][] bindings for [libspotify][], the official Spotify C API. This allows you to use an awesome language to interact with an awesome service.

Hallon is inspired by [Greenstripes][], a similar library by [Jesper Särnesjö][].

This is awesome! I want to help!
--------------------------------
Sweet! You contribute in more than one way!

### Write code!
[Fork Hallon](http://github.com/Burgestrand/Hallon), [write tests for everything](http://relishapp.com/rspec) you do (so I don’t break your stuff during my own development) and send a pull request. If you modify existing files, please adhere to the coding standard surrounding your code!

### [Send me feedback and requests](http://github.com/Burgestrand/Hallon/issues)
Really, I ❤ feedback! Suggestions on how to improve the API, tell me what is delicious about Hallon, tell me what is yucky about Hallon… anything! All feedback is useful in one way or another.

You can reach me either through [Hallons issue tracker](http://github.com/Burgestrand/Hallon/issues), [GitHub messaging system](http://github.com/inbox/new/Burgestrand) or you can find [more contact details on my GitHub profile](http://github.com/Burgestrand).

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