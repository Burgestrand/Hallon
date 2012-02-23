[What is Hallon?][] [![Build Status][]](http://travis-ci.org/Burgestrand/Hallon)
===================

Hallon — which is Swedish for “[Raspberry][]” — is a ruby gem for interacting with the official Spotify C API. It is written on top of [Spotify for Ruby][], with the goal of making the experience of using [libspotify][] as enjoyable as it can be.

Hallon would not have been possible if not for these people:

- Per Reimers, cracking synchronization bugs with me in the deep night (4 AM) and correcting me when I didn’t know better
- Spotify, providing a service worth attention (and my money!)
- Linus Oleander, originally inspiring me to write Hallon (for the radiofy.se project)

Also, these people are worthy of mention simply for their contribution:

- Jesper Särnesjö, unknowingly providing me a starting point with [Greenstripes][]
- Emil “@mrevilme” Palm, for his patience in helping me debug Hallon deadlock issues

Code samples can be found under the `examples/` directory. An explanation on how to run them can be found on the [Hallon wiki on GitHub](https://github.com/Burgestrand/Hallon/wiki).

Installation
------------

    gem install hallon

If you want to play audio you’ll need to install an audio driver. As of current writing there is only one driver in existence. You can install it with:

    gem install hallon-openal

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
Some objects may fire callbacks, most of the time as a direct result of [Session#process_events][]. In libspotify the callbacks are only fired once for every object, but in Hallon you may have more than one object attached to the same libspotify object. As a result, callbacks are handled individually for each Hallon object, and in the case of a required return value the last handler is what decides the final return value.

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

A list of all objects that can fire callbacks can be found on the [API page for Hallon::Observable][].

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
Hallon supports streaming audio from Spotify via [Hallon::Player][]. When you create the player you give it your current session and an audio driver, which the player will then use for audio playback.

```ruby
player = Hallon::Player.new(session, Hallon::OpenAL)
player.play(loaded_track)
```

Available drivers are:

- [Hallon::OpenAL](https://rubygems.org/gems/hallon-openal)

        gem install hallon-openal

For information on how to write your own audio driver, see [Hallon::ExampleAudioDriver].

You have any questions?
-----------------------
I can be reached at my [email (found on GitHub profile)](http://github.com/Burgestrand) or [@burgestrand on twitter](http://twitter.com/Burgestrand). I’d be extremely happy to discuss Hallon with
you if you have any feedback or thoughts.

For issues and feature requests, please use use [Hallons issue tracker](http://github.com/Burgestrand/Hallon/issues).

This is awesome! I want to help!
--------------------------------
Sweet! You contribute in more than one way!

### Write code!
[Fork](http://help.github.com/forking/) Hallon, [write tests for everything](http://relishapp.com/rspec) you do (so I don’t break your stuff during my own development) and send a pull request. If you modify existing files, please adhere to the coding standard surrounding your code!

### [Send me feedback and requests](http://github.com/Burgestrand/Hallon/issues)
Really, I ❤ feedback! Suggestions on how to improve the API, tell me what is delicious about Hallon, tell me what is yucky about Hallon… anything! All feedback is useful in one way or another.

Finally, here are some important notes
--------------------------------------

### Hallon only supports one session per process
You can only keep one session with Spotify alive at a time within the same process, due to a limitation of libspotify.

### When forking, you need to be extra careful
If you fork, you need to instantiate the session within the process you plan to use Hallon in. You want to use Hallon in the parent? Create the session in the parent. You want to use it in the child? Create the session in the child! This is a limitation of libspotify itself.

Versioning policy
-----------------
Hallon uses [semantic versioning](http://semver.org) as of v0.0.0. As long
as Hallon stays at major version 0, no guarantees of backwards-compatibility
are made. `CHANGELOG.md` will be kept up to date with the different versions.

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

[API page for Hallon::Observable]: http://rubydoc.info/github/Burgestrand/Hallon/master/Hallon/Observable

[Hallon::Enumerator]:         http://rubydoc.info/github/Burgestrand/Hallon/Hallon/Enumerator
[Hallon::Error]:              http://rubydoc.info/github/Burgestrand/Hallon/Hallon/Error
[Hallon::Player]:             http://rubydoc.info/github/Burgestrand/Hallon/Hallon/Player
[Hallon::ExampleAudioDriver]: http://rubydoc.info/github/Burgestrand/Hallon/Hallon/ExampleAudioDriver

[Session#process_events]:     http://rubydoc.info/github/Burgestrand/Hallon/Hallon/Session:process_events
[Session.initialize]:         http://rubydoc.info/github/Burgestrand/Hallon/Hallon/Session.initialize
[Track#artists]:              http://rubydoc.info/github/Burgestrand/Hallon/Hallon/Track:artists
[#load]:                      http://rubydoc.info/github/Burgestrand/Hallon/Hallon/Loadable:load