# coding: utf-8
require 'timeout'

module Hallon
  # Extends Hallon objects with a method that allows synchronous loading of objects.
  module Loadable
    # Wait until the object has loaded.
    #
    # @example waiting for a track to load
    #   track = Hallon::Track.new(track_uri).load
    #
    # @param [Numeric] timeout after this time, if the object is not loaded, an error is raised.
    # @return [self]
    # @raise [Hallon::TimeoutError] after `timeout` seconds if the object does not load.
    def load(timeout = Hallon.load_timeout)
      Timeout.timeout(timeout, Hallon::TimeoutError) do
        until loaded?
          session.process_events

          if respond_to?(:status)
            Error.maybe_raise(status, :ignore => :is_loading)
          end

          sleep(0.001)
        end

        self
      end
    end
  end
end
