# coding: utf-8

module Hallon
  module Loadable
    # @param [Numeric] timeout after this time, if the object is not loaded, an error is raised.
    # @return [self]
    # @raise [Hallon::TimeoutError] after `timeout` seconds if the object does not load.
    def load(timeout = Hallon.load_timeout)
      Timeout.timeout(timeout, Hallon::TimeoutError) do
        until loaded?
          session.process_events
          sleep(0.001)
        end

        self
      end
    end
  end
end
