# coding: utf-8
module Hallon
  class Session
    class Callbacks
      attr_reader :session
      def initialize(session)
        @session = session
      end
      
      def logged_in(error)
        puts "(FIRED) logged_in(#{error})"
      end
    end
  end
end