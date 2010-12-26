# coding: utf-8
module Hallon
  class Session
    private
      alias_method :_process_events, :process_events
      def process_events
        print "(FIRED) process_events\n\t"
        timeout = _process_events
        puts "… done!"
      end
    
      def logged_in(error)
        puts "(FIRED) logged_in(#{error})"
      end
  end
end