require 'monitor'

class Monitor
  module Extensions
    # Monitor::ConditionVariable#wait_until with a timeout
    #
    # @param [nil, Fixnum] timeout
    # @yield called to query if waiting should continue
    def wait_for(n = nil)
      wait(n) until yield
    end
  end
end
