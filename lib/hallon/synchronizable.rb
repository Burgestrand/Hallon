require 'monitor'
require 'forwardable'

module Hallon
  module Synchronizable
    # Required for thread-safety around #monitor
    IMonitor = Monitor.new

    extend Forwardable
    def_delegators :monitor, :synchronize, :new_cond

    private
      # Retrieve our Monitor instance, creating a new one if necessary.
      #
      # @note This function is thread-safe.
      # @return [Monitor]
      def monitor
        IMonitor.synchronize { @monitor ||= Monitor.new }
      end
  end
end
