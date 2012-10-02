[What is Hallon?][] [![Build Status][]](http://travis-ci.org/Burgestrand/Hallon)
===================

Hallon (Swedish for “[Raspberry][]”) is _the_ ruby gem for interacting with the official Spotify C API. It is the only ruby gem for libspotify that is up-to-date and usable. My goal with Hallon is to make libspotify a joy to use.

Code samples can be found under the `examples/` directory. An explanation on how to run them can be found on the [Hallon wiki on GitHub](https://github.com/Burgestrand/Hallon/wiki).

### Contact details

- __Got questions?__ Ask on the mailing list: <mailto:ruby-hallon@googlegroups.com> (<https://groups.google.com/d/forum/ruby-hallon>)
- __Found a bug?__ Report an issue: <https://github.com/Burgestrand/Hallon/issues/new>
- __Have feedback?__ I ❤ feedback! Please send it to the mailing list.

If you for some reason cannot use the mailing list or GitHub issue tracker you may contact me directly. My email is found on [my GitHub profile](https://github.com/Burgestrand), and I’m also available as [@burgestrand on twitter](https://twitter.com/Burgestrand).

Prerequisites
-------------

Before you start using Hallon you’ll need to complete the following steps.

1. Get yourself a Spotify premium account, which is required for libspotify to work. You username and password
   (either classic Spotify, or facebook credentials) will be used to connect to Spotify later.
2. [Download your application key from developer.spotify.com](https://developer.spotify.com/en/libspotify/application-key/),
   and place it in a known location. You’ll have the option of downloading it either in **binary** or c-code. You want the
   **binary** one. If you do not have an application key already, you will be asked to create one.
3. Once the above are done, you are ready to try out Hallon.

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
As long as Hallon stays at major version 0 its API should be considered experimental. I expect it to change a lot to version v1.0.0.

Hallon is not without version policy, however. As of version **v0.18.0** I aim to only increase the minor version when backwards-incompatible
changes are made. Therefore, it should be safe to upgrade between minor versions, i.e. specify version constraints with the patch version as
the variable version: `hallon ~> v0.18.0`.

### Hallon only supports one session per process
You can only keep one session with Spotify alive at a time within the same process, due to a limitation of libspotify.

### When forking, you need to be extra careful
If you fork, you need to instantiate the session within the process you plan to use Hallon in. You want to use Hallon in the parent? Create the session in the parent. You want to use it in the child? Create the session in the child! This is a limitation of libspotify itself.

### Hallon and platforms
Hallon aims to support the available platforms of the Spotify gem, which in turn depends somewhat on the platforms that libspotify support. As of current, Hallon officially supports Mac OS and Linux distributions that libspotify supports. Windows support is possible, but is yet to have been needed.

### Having trouble with libspotify missing?
If so, it may be the case that your platform is not supported by the [libspotify gem](http://rubygems.org/gems/libspotify). Hallon’s wiki has an article on [How to install libspotify](https://github.com/Burgestrand/Hallon/wiki/How-to-install-libspotify) for you. However, please also [report an issue on the libspotify gem](https://github.com/Burgestrand/libspotify/issues), I’d appreciate it, thank you!

Credits
-------
- Per Reimers, cracking synchronization bugs with me deep in the night (4 AM), thanks. :)
- Jesper Särnesjö, unknowingly providing me a starting point with [Greenstripes][]
- Linus Oleander, originally inspiring me to write Hallon (for the radiofy.se project)
- Emil “@mrevilme” Palm, for his patience in helping me debug Hallon deadlock issues

License
-------
Hallon is licensed under a 2-clause (Simplified) BSD license.

Copyright 2012 Kim Burgestrand. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright notice, this list
      of conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY KIM BURGESTRAND ``AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL KIM BURGESTRAND OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[Raspberry]:        http://images.google.com/search?q=raspberry&tbm=isch
[Spotify for Ruby]: https://github.com/Burgestrand/spotify
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
