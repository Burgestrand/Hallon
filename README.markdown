# What’s this?
This is [Ruby](http://www.ruby-lang.org/en/) bindings for the official Spotify API. What this means is that you can use Ruby to interact with Spotify.

Hallon is inspired by [Greenstripes](http://github.com/sarnesjo/greenstripes), a similar library by [Jesper Särnesjö](http://jesper.sarnesjo.org/).

# … why?
I need a library to interface with Spotify for another project that I’ve named “restify” — which is a HTTP REST gateway to the Spotify API, used internally for yet another project.

# How do I use it?
`libspotify` itself needs a [Spotify premium account](https://www.spotify.com/se/get-spotify/premium/), and subsequently an application key. If you have both, follow these steps:

- download and install `libspotify`
- build the C extension: `rake build`
- see the tests pass: `rake test`

## How do I install `libspotify`?
Installing `libspotify` means you need to put the binary library and the headers on a location where GCC can find them. First of all, [download the library](https://developer.spotify.com/en/libspotify/overview/)

### … on Mac OS?
Copy the `libspotify.framework` folder to `/Library/Frameworks/libspotify.framework`, Hallon handles the rest. :)

## License
[GNU AGPL](http://en.wikipedia.org/wiki/Affero_General_Public_License), but I might change it to a less viral license in the near future.