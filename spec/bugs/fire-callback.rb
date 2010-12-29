$: << File.expand_path('../../../lib', __FILE__)
require 'hallon'
require_relative '../support/config'

Thread.abort_on_exception = true

module Hallon
  class Session
    class Callbacks
      def destroy
        throw :shuriken
      end
    
      def noop
        puts "Noop"
      end
    end
  end
end

sess = Hallon::Session.instance(Hallon::APPKEY)

5.times { sess.fire! :noop }
sess.fire! :destroy
sleep 2