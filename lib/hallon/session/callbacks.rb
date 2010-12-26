# coding: utf-8
module Hallon
  class Session
    private
      alias_method :_process_events, :process_events
      def process_events
        puts "Processing events…"
        timeout = _process_events
        puts "Done!"
      end
    
      def logged_in(error)
        puts "?? logged_in(#{error})"
      end
  end
end