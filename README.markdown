# What’s this?
This is [Ruby](http://www.ruby-lang.org/en/) bindings for the official Spotify API. What this means is that you can use Ruby to interact with Spotify.

Hallon is inspired by [Greenstripes](http://github.com/sarnesjo/greenstripes), a similar library by [Jesper Särnesjö](http://jesper.sarnesjo.org/).

# … why?
I need a library to interface with Spotify for another project that I’ve named “restify” — which is a HTTP REST gateway to the Spotify API, used internally for yet another project.

# How do I use it?
`libspotify` itself needs a [Spotify premium account](https://www.spotify.com/se/get-spotify/premium/), and subsequently an application key. If you have both, follow these steps:

- download and install `libspotify`
- download Hallon: `git clone git://github.com/Burgestrand/Hallon.git; cd Hallon`
- build the extension and test it: `rake build`
- build the gem `rake gem; gem install Hallon-*.gem`

For a list of available commands use `rake -T`.

## How do I install `libspotify`?
Installing `libspotify` means you need to put the binary library and the headers on a location where GCC can find them. First of all, [download the library](https://developer.spotify.com/en/libspotify/overview/)

### … on Mac OS?
Copy the `libspotify.framework` folder to `/Library/Frameworks/libspotify.framework`, Hallon handles the rest. :)

## What’s the catch?
There are several!

### Hallon is unstable
I’ve never developed anything in C before, and I’ve been using Ruby for about a month. With that said, Hallon most likely leaks memory and should be considered experimental.

### Hallon only supports one session per process
You can only keep one session with Spotify alive at a time in the same process, due to a limitation of `libspotify`.

### Hallon is licensed under GNU AGPL
Hallon is licensed under the [GNU AGPL](http://www.gnu.org/licenses/agpl-3.0.html), which is a very viral license. In summary, anything that is using Hallon in any way must also be open sourced (and source must be available for its’ users) under the GNU AGPL. I might change the license to a less viral one in the future.