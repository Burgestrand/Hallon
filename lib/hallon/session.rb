# coding: utf-8
require 'singleton'
require 'timeout'
require 'thread'

module Hallon
  # The Session is fundamental for all communication with Spotify.
  # Pretty much all API calls require you to have established a session
  # with Spotify before using them.
  #
  # @see https://developer.spotify.com/en/libspotify/docs/group__session.html
  class Session < Base
    # The options Hallon used at {Session#initialize}.
    #
    # @return [Hash]
    attr_reader :options

    # libspotify only allows one session per process.
    include Singleton
    class << self
      undef :instance
    end

    # Session allows you to define your own callbacks.
    include Hallon::Observable

    # Initializes the Spotify session. If you need to access the
    # instance at a later time, you can use {instance}.
    #
    # @see Session.instance
    # @see Session#initialize
    #
    # @param (see Session#initialize)
    # @return [Session]
    def Session.initialize(*args, &block)
      raise "Session has already been initialized" if @__instance__
      @__instance__ = new(*args, &block)
    end

    # Returns the previously initialized Session.
    #
    # @see Session.instance
    #
    # @return [Session]
    def Session.instance
      @__instance__ or raise "Session has not been initialized"
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
      config[:api_version]   = Hallon::API_VERSION
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

    # Wait for the given callbacks to fire until the block returns true
    #
    # @param [Symbol, ...] *events list of events to wait for
    # @yield [Symbol, *args] name of the callback that fired, and its’ arguments
    # @return [Hash<Event, Arguments>]
    def process_events_on(*events)
      yield or protecting_handlers do
        channel = SizedQueue.new(1)
        on(*events) { |*args| channel << args }
        on(:notify_main_thread) { channel << :notify }

        loop do
          begin
            process_events
            params = Timeout::timeout(0.25) { channel.pop }
            redo if params == :notify
          rescue Timeout::Error
            params = :timeout
          end

          if result = yield(*params)
            return result
          end
        end
      end
    end
    alias :wait_for :process_events_on

    # Log into Spotify using the given credentials.
    #
    # @param [String] username
    # @param [String] password
    # @param [Boolean] remember_me have libspotify remember credentials for {relogin}
    # @return [self]
    def login(username, password, remember_me = false)
      tap { Spotify::session_login(@pointer, username, password, @remembered = remember_me) }
    end

    # Logs out of Spotify. Does nothing if not logged in.
    #
    # @return [self]
    def logout
      tap { Spotify::session_logout(@pointer) if logged_in? }
    end

    # Retrieve the currently logged in {User}.
    #
    # @return [User]
    def user
      User.new Spotify::session_user(@pointer)
    end

    # Retrieve the relation type between logged in {User} and `user`.
    #
    # @return [Symbol] :unknown, :none, :unidirectional or :bidirectional
    def relation_type?(user)
      Spotify::user_relation_type(@pointer, user.pointer)
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

    # String representation of the Session.
    #
    # @return [String]
    def to_s
      "<#{self.class.name}>"
    end
  end
end
