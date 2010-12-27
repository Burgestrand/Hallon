# coding: utf-8
module Hallon
  class Session
    private
      def logged_in(error)
        puts "(FIRED) logged_in(#{error})"
      end
  end
end