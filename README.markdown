[What is Hallon?][] [![Build Status][]](http://travis-ci.org/Burgestrand/Hallon)
===================

Hallon (Swedish for “[Raspberry][]”) is _the_ ruby gem for interacting with the official Spotify C API. It is the only ruby gem for libspotify that is up-to-date and usable. My goal with Hallon is to make libspotify a joy to use.

Code samples can be found under the `examples/` directory. An explanation on how to run them can be found on the [Hallon wiki on GitHub](https://github.com/Burgestrand/Hallon/wiki).

Prerequisites
-------------

Before you start using Hallon you’ll need to complete the following steps.

1. Get yourself a Spotify premium account, which is required for libspotify to work. You username and password
   (either classic Spotify, or facebook credentials) will be used to connect to Spotify later.
2. [Download your application key from developer.spotify.com](https://developer.spotify.com/en/libspotify/application-key/),
   and place it in a known location. You’ll have the option of downloading it either in **binary** or c-code. You want the
   **binary** one. If you do not have an application key already, you will be asked to create one.
3. Install libspotify. Hallon always aims to support to most recent version, which is currently **v12.1.45**. Older
   versions are not supported. For help installing libspotify, please see the wiki on [How to install libspotify][].
4. Once the above are done, you are ready to try out Hallon.

### Using Hallon

First, begin by installing the latest version of Hallon.

```bash
gem install hallon
```

Great! Now you’re ready to start experimenting. Everything in Hallon, from searching to looking up tracks, requires you to
have an active Spotify session. You create it by initializing it with your application key.

```ruby
require 'hallon'

session = Hallon::Session.initialize IO.read('./spotify_appkey.key')
```

Now that you have your session you may also want to login (even though you can still do a few things without logging in).

```ruby
session.login!('username', 'password')
```

You may now experiment with just about anything. For an API reference, please see [Hallon’s page at rdoc.info](http://rdoc.info/github/Burgestrand/Hallon/master/frames).
As a starter tip, many objects can be constructed by giving it a Spotify URI, like this.

```ruby
track = Hallon::Track.new("spotify:track:1ZPsdTkzhDeHjA5c2Rnt2I").load
artist = track.artist.load

puts "#{track.name} by #{artist.name}"
```

### If you want to play audio…

If you want to play audio you’ll need to install an audio driver. As of current writing there is only one driver in existence. You can install it with:

```bash
gem install hallon-openal
```

For more information about audio support in Hallon, see the section "Audio support" below.

### Contact details

- __Got questions?__ Ask on the mailing list: <mailto:ruby-hallon@googlegroups.com> (<https://groups.google.com/d/forum/ruby-hallon>)
- __Found a bug?__ Report an issue: <https://github.com/Burgestrand/Hallon/issues/new>
- __Have feedback?__ I ❤ feedback! Please send it to the mailing list.

If you for some reason cannot use the mailing list or GitHub issue tracker you may contact me directly. My email is found on [my GitHub profile](https://github.com/Burgestrand), and I’m also available as [@burgestrand on twitter](https://twitter.com/Burgestrand).

Hallon and Spotify objects
--------------------------
All objects from libspotify have a counterpart in Hallon, and just like in libspotify the objects are populated with information as it becomes available. All objects that behave in this way respond to `#loaded?`, which’ll return true if the object has been populated with data.

To ease loading objects, all loadable objects also respond to [#load][]. This method simply polls on the target object, repeatedly calling [Session#process_events][] until either a time limit is reached or the object has finished loading.

```ruby
user = Hallon::User.new("spotify:user:burgestrand").load
puts user.loaded? # => true
```

As far as usage of the library goes, what applies to libspotify also applies to Hallon, so I would suggest you also read [the libspotify library overview](http://developer.spotify.com/en/libspotify/docs/) and related documentation.

### Callbacks
Some objects may fire callbacks, most of the time as a direct result of [Session#process_events][]. In libspotify the callbacks are only fired once for every object, but in Hallon you may have more than one object attached to the same libspotify object. As a result, callbacks are handled individually for each Hallon object.

```ruby
imageA = Hallon::Image.new("spotify:image:548957670a3e9950e87ce61dc0c188debd22b0cb")
imageB = Hallon::Image.new("spotify:image:548957670a3e9950e87ce61dc0c188debd22b0cb")

imageA.pointer == imageB.pointer # => true, same spotify pointer
imageA.object_id == imageB.object_id # => false, different objects

imageA.on(:load) do
  puts "imageA loaded!"
end

imageB.on(:load) do
  puts "imageB loaded!"
end

imageA.load # might load imageB as well, we don’t know
imageB.load # but the callbacks will both fire on load
```

A list of all objects that may fire callbacks can be found on the [API page for Hallon::Observable][].

### Errors
On failed libspotify API calls, a [Hallon::Error][] will be raised with a message explaining the error. Methods that might fail in this way (e.g. [Session.initialize][]) should have this clearly stated in its’ documentation.

For a full list of possible errors, see [the official libspotify documentation on error handling](http://developer.spotify.com/en/libspotify/docs/group__error.html).

### Enumerators
Some methods (e.g. [Track#artists][]) return a [Hallon::Enumerator][] object. Enumerators are lazily loaded, which means that calling `track.artists` won’t create any artist objects until you try to retrieve one of the records out of the returned enumerator. If you want to load all artists for a track you should retrieve them all then load them in bulk.

```ruby
artists = track.artists.to_a # avoid laziness, instantiate all artist objects
artists.map(&:load)
```

An additional note is that the size of an enumerator may change, and its contents may move as libspotify updates its information.

For the API reference and existing subclasses, see [Hallon::Enumerator][].

### Garbage collection
Hallon makes use of Ruby’s own garbage collection to automatically release libspotify objects when they are no longer in use. There is no need to retain or release the spotify objects manually.

Audio support
-------------
Hallon supports streaming audio from Spotify via [Hallon::Player][]. When you create the player you give it your audio driver of choice, which the player will then use for audio playback.

```ruby
require 'hallon'
require 'hallon-openal'

session = Hallon::Session.initialize(IO.read('./spotify_appkey.key'))
session.login!('username', 'password')

track = Hallon::Track.new("spotify:track:1ZPsdTkzhDeHjA5c2Rnt2I")
track.load

player = Hallon::Player.new(Hallon::OpenAL)
player.play!(track)
```

Available drivers are:

- [Hallon::OpenAL](https://rubygems.org/gems/hallon-openal)

      gem install hallon-openal

For information on how to write your own audio driver, see [Hallon::ExampleAudioDriver][].

Finally, here are some important notes
--------------------------------------

### Contributing to Hallon
[Fork](http://help.github.com/forking/) Hallon, write tests for everything you do (so I don’t break your stuff during my own development) and send a pull request. If you modify existing files, please adhere to the coding standard surrounding your code.

### Hallon uses [semantic versioning](http://semver.org) as of v0.0.0
As long as Hallon stays at major version 0, no guarantees of backwards-compatibility are made. `CHANGELOG.md` will be kept up to date with the different versions.

### Hallon only supports one session per process
You can only keep one session with Spotify alive at a time within the same process, due to a limitation of libspotify.

### When forking, you need to be extra careful
If you fork, you need to instantiate the session within the process you plan to use Hallon in. You want to use Hallon in the parent? Create the session in the parent. You want to use it in the child? Create the session in the child! This is a limitation of libspotify itself.

Credits
-------
- Per Reimers, cracking synchronization bugs with me deep in the night (4 AM), thanks. :)
- Jesper Särnesjö, unknowingly providing me a starting point with [Greenstripes][]
- Linus Oleander, originally inspiring me to write Hallon (for the radiofy.se project)
- Emil “@mrevilme” Palm, for his patience in helping me debug Hallon deadlock issues

License
-------
Hallon is licensed under a 2-clause (Simplified) BSD license. More information can be found in the `LICENSE.txt` file.

[Raspberry]:        http://images.google.com/search?q=raspberry&tbm=isch
[Spotify for Ruby]: https://github.com/Burgestrand/libspotify-ruby
[spotify gem]:      https://rubygems.org/gems/spotify
[libspotify]:       http://developer.spotify.com/en/libspotify/overview/
[Greenstripes]:     http://github.com/sarnesjo/greenstripes
[What is Hallon?]:  http://burgestrand.se/articles/hallon-delicious-ruby-bindings-to-libspotify.html
[Build Status]:     https://secure.travis-ci.org/Burgestrand/Hallon.png

[How to install libspotify]: https://github.com/Burgestrand/Hallon/wiki/How-to-install-libspotify

[API page for Hallon::Observable]: http://rubydoc.info/github/Burgestrand/Hallon/master/Hallon/Observable

[Hallon::Enumerator]:         http://rubydoc.info/github/Burgestrand/Hallon/Hallon/Enumerator
[Hallon::Error]:              http://rubydoc.info/github/Burgestrand/Hallon/Hallon/Error
[Hallon::Player]:             http://rubydoc.info/github/Burgestrand/Hallon/Hallon/Player
[Hallon::ExampleAudioDriver]: http://rubydoc.info/github/Burgestrand/Hallon/Hallon/ExampleAudioDriver

[Session#process_events]:     http://rubydoc.info/github/Burgestrand/Hallon/Hallon/Session:process_events
[Session.initialize]:         http://rubydoc.info/github/Burgestrand/Hallon/Hallon/Session.initialize
[Track#artists]:              http://rubydoc.info/github/Burgestrand/Hallon/Hallon/Track:artists
[#load]:                      http://rubydoc.info/github/Burgestrand/Hallon/Hallon/Loadable:load
