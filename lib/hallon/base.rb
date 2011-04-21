require 'monitor'

module Hallon
  # A module providing event capabilities to Hallon objects.
  # 
  # @private
  module Base
    # Required for maintaining thread-safety around #monitor.
    IMonitor = Monitor.new
    
    # Defines a handler for the given event.
    # 
    # @example
    #   o = Object.new
    #   o.instance_eval { include Hallon::Base }
    #   
    #   on(:callback) do |*args|
    #     # handle it
    #   end
    # 
    #   o.on_callback("Moo!")
    # 
    # @param [#to_s] event name of event to handle
    # @yield (*args) event handler block
    # @see #initialize
    def on(event, &block)
      define_singleton_method(:"on_#{event}", &block)
    end
    
    # Run the given block, protecting all previous event handlers.
    # 
    # @example
    #   o = Object.new
    #   o.instance_eval { include Hallon::Base }
    #   o.on(:method) { "outside" }
    #   
    #   puts o.on_method # => "outside"
    #   o.protecting_handlers do
    #     o.on(:method) { "inside" }
    #     puts o.on_method # => "inside"
    #   end
    #   puts o.on_method # => "outside"
    # 
    # @yield
    # @return whatever the given block returns
    def protecting_handlers
      on_method = method(:on)
      overridden_callbacks = {}
      
      define_singleton_method(on_method.name) do |event, &block|
        handler_name = :"on_#{event}"
        if respond_to?(handler_name, true)
          overridden_callbacks[handler_name] = method(handler_name)
        end
        
        on_method.call(event, &block)
      end
      
      yield
    ensure
      define_singleton_method(on_method.name, &on_method)
      overridden_callbacks.each_pair do |event, handler|
        define_singleton_method(event, handler)
      end
    end
    
    # Conceive a new condition variable bound to this object.
    # 
    # @see Monitor#new_cond
    # @return [Monitor::ConditionVariable]
    def new_cond
      monitor.new_cond
    end
    
    # Execute a code block under a critical (thread-safe) time slice.
    # 
    # @see Monitor#synchronize
    def synchronize(&block)
      monitor.synchronize(&block)
    end
    
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