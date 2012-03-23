# coding: utf-8

require_relative 'example_support'
session = Hallon::Session.instance

while username = prompt("Enter a Spotify username: ")
  begin
    puts "Loading #{username}."
    user = Hallon::User.new(username)

    puts "Fetching published playlists for #{username}..."
    published = user.published.load

    puts "Loading #{published.size} playlists."
    all_playlists = published.contents.find_all do |playlist|
      playlist.is_a?(Hallon::Playlist) # ignore folders
    end

    all_playlists.each(&:load)

    all_playlists.each do |playlist|
      puts
      puts "Listing tracks for #{playlist.name} (#{playlist.to_str}):"

      tracks = playlist.tracks.to_a.map(&:load)
      tracks.each_with_index do |track, i|
        puts "\t (#{i+1}/#{playlist.size}) #{track.name}"
      end
    end
  rescue Interrupt
    puts "Interrupted!"
  end
end
