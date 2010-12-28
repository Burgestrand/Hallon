$: << File.expand_path('../../../lib', __FILE__)
require 'hallon'
require_relative '../support/config'

module Hallon
  class Session
    private
      def noop(*args)
        # noop
      end
  end
end

sess = Hallon::Session.instance Hallon::APPKEY

5.times { sess.fire! :noop }
sleep 5