# coding: utf-8
require 'singleton'

module Hallon
  # The Session is fundamental for all communication with Spotify.
  # Pretty much all API calls require you to have established a session
  # with Spotify before using them.
  # 
  # @see https://developer.spotify.com/en/libspotify/docs/group__session.html
  class Session
    # The options Hallon used at {Session#initialize}.
    # 
    # @return [Hash]
    attr_reader :options
    
    # Application key used at {Session#initialize}
    #
    # @return [String]
    attr_reader :appkey
    
    # libspotify only allows one session per process.
    include Singleton
    
    # Session allows you to define your own callbacks.
    include Hallon::Base
    
    # Allows you to create a Spotify session. Subsequent calls to this method
    # will return the previous instance, ignoring any passed arguments.
    #
    # @param (see Session#initialize)
    # @see Session#initialize
    # @return [Session]
    def Session.instance(*args, &block)
      @__instance__ ||= new(*args, &block)
    end
    
    # Create a new Spotify session.
    # 
    # @param [#to_s] appkey
    # @param [Hash] options
    # @option options [String] :user_agent ("Hallon") User-Agent to use (length < 256)
    # @option options [String] :settings_path ("tmp") where to save settings and user-specific cache
    # @option options [String] :cache_path ("") where to save cache files (set to "" to disable)
    # @option options [Bool]   :load_playlists (true) load playlists into RAM on startup
    # @option options [Bool]   :compress_playlists (true) compress local copies of playlists
    # @option options [Bool]   :cache_playlist_metadata (true) cache metadata for playlists locally
    # @yield allows you to define handlers for events (see {Hallon::Base#on})
    # @raise [ArgumentError] if `options[:user_agent]` is more than 256 characters long
    # @raise [Hallon::Error] if `sp_session_create` fails
    # @see http://developer.spotify.com/en/libspotify/docs/structsp__session__config.html
    def initialize(appkey, options = {}, &block)
      @appkey  = appkey.to_s
      @options = {
        :user_agent => "Hallon",
        :settings_path => "tmp",
        :cache_path => "",
        :load_playlists => true,
        :compress_playlists => true,
        :cache_playlist_metadata => true
      }.merge(options)
      
      if @options[:user_agent].bytesize > 255
        raise ArgumentError, "User-agent must be less than 256 bytes long"
      end
      
      # Set configuration, as well as callbacks
      config  = Spotify::SessionConfig.new
      config[:api_version]   = Spotify::API_VERSION
      config.application_key = @appkey
      @options.each { |(key, value)| config.send(:"#{key}=", value) }
      config[:callbacks]     = Spotify::SessionCallbacks.new(self, @sp_callbacks = {})
      
      instance_eval(&block) if block_given?
      
      # You pass a pointer to the session pointer to libspotify >:)
      FFI::MemoryPointer.new(:pointer) do |p|
        Hallon::Error::maybe_raise Spotify::session_create(config, p)
        @pointer = p.read_pointer
      end
    end
    
    # Process pending Spotify events (might fire callbacks).
    # 
    # @return [Fixnum] minimum time until it should be called again
    def process_events
      FFI::MemoryPointer.new(:int) do |p|
        Spotify::session_process_events(@pointer, p)
        return p.read_int
      end
    end
    
    # Log into Spotify using the given credentials.
    # 
    # @param [String] username
    # @param [String] password
    # @return [self]
    def login(username, password)
      Spotify::session_login(@pointer, username, password)
      self
    end
    
    # Logs out of Spotify. Does nothing if not logged in.
    # 
    # @return [self]
    def logout
      Spotify::session_logout(@pointer) if logged_in?
      self
    end
    
    # Retrieve current connection status.
    # 
    # @return [Symbol]
    def status
      Spotify::session_connectionstate(@pointer)
    end
    
    # True if currently logged in.
    # @see #status
    def logged_in?
      status == :logged_in
    end
    
    # True if logged out.
    # @see #status
    def logged_out?
      status == :logged_out
    end
    
    # True if session has been disconnected.
    # @see #status
    def disconnected?
      status == :disconnected
    end
  end
end