require 'monitor'
require 'forwardable'

module Hallon
  # Adds synchronization primitives to target when included.
  module Synchronizable
    # Creates a `Monitor` for the target instance and adds `monitor` class method for access.
    #
    # Also adds several other methods:
    #
    # - `#synchronize`
    # - `#new_cond`
    #
    # These all delegate to `#monitor`.
    def self.included(o)
      o.instance_exec do
        @monitor = Monitor.new
        class << self
          attr_reader :monitor
        end
      end
    end

    extend Forwardable
    def_delegators :monitor, :synchronize, :new_cond
    def_delegators 'self.class', :monitor
  end
end
