What is Hallon?
===============
We rubyists have this awesome [spotify gem][] allowing us to use [libspotify][] from within Ruby, but it has a significant drawback: the `libspotify` API is very hard to use. Now, we can’t have that, so what do we do? We make Hallon!

Hallon is Swedish for “Raspberry”, and has been written to satisfy my needs for API simplicity. It provides you with a wrapper around the spotify gem, making the experience of using `libspotify` from Ruby much more enjoyable.

Hallon would not have been possible if not for these people:

- Per Reimers, cracking synchronization bugs with me in the deep night (4 AM) and correcting me when I didn’t know better
- [Spotify](http://www.spotify.com/), providing a service worth attention (and my money!)
- [Linus Oleander](https://github.com/oleander), involving me with the `radiofy.se` project, ultimately spawning the necessity of Hallon
- [Jesper Särnesjö][], creator of [Greenstripes][], making me think of Hallon as an achievable goal

Code samples can be found under `examples/` directory.

This is awesome! I want to help!
--------------------------------
Sweet! You contribute in more than one way!

### Write code!
[Fork](http://help.github.com/forking/) Hallon, [write tests for everything](http://relishapp.com/rspec) you do (so I don’t break your stuff during my own development) and send a pull request. If you modify existing files, please adhere to the coding standard surrounding your code!

### [Send me feedback and requests](http://github.com/Burgestrand/Hallon/issues)
Really, I ❤ feedback! Suggestions on how to improve the API, tell me what is delicious about Hallon, tell me what is yucky about Hallon… anything! All feedback is useful in one way or another.

You have any questions?
-----------------------
If you need to discuss issues or feature requests you can use [Hallons issue tracker](http://github.com/Burgestrand/Hallon/issues). For *anything* else you have to say or ask I can also be reached via [email (found on GitHub profile)](http://github.com/Burgestrand) or [@burgestrand on twitter](http://twitter.com/Burgestrand).

In fact, you can contact me via email or twitter even if it’s about features or issues. I’ll probably put them in the issue tracker myself after the discussion ;)

What’s the catch?
-----------------
There are several!

### Hallon is unstable
The API is unstable, my code is likely unstable. Everything should be considered unstable!

### Hallon only supports one session per process
You can only keep one session with Spotify alive at a time in the same process, due to a limitation of `libspotify`.

### You still have to worry about threads
I have been doing my best at hiding the complexity in `libspotify`, but it’s still a work in progress. Despite my efforts, you’ll need to be familiar with concurrent programming to use Hallon properly.

Versioning policy
-----------------
Hallon uses [semantic versioning](http://semver.org) as of v0.0.0. As long
as Hallon stays at major version 0, no guarantees of backwards-compatibility
are made. CHANGELOG will be kept up to date with the different versions.

License
-------
Hallon is licensed under a 2-clause (Simplified) BSD license. More information can be found in the `LICENSE.txt` file.

[spotify gem]: https://rubygems.org/gems/spotify
[libspotify]: http://developer.spotify.com/en/libspotify/overview/
[Greenstripes]: http://github.com/sarnesjo/greenstripes
[Jesper Särnesjö]: http://jesper.sarnesjo.org/
