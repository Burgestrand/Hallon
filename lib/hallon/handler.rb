# coding: utf-8
module Hallon
  module Handler
    # Build a handler given either a class, module and/or block.
    #
    # @private
    # @see Hallon::Handler
    # @param [Class<Hallon::Handler>, Module, nil] handler
    # @param [Block, nil] block
    # @return [Hallon::Handler]
    def Handler.build(handler = nil, block = nil)
      klass = if handler.is_a?(Class)
        raise ArgumentError, "must provide nil, module, or subclass of Hallon::Handler" unless Hallon::Handler >= handler
        handler
      else
        Class.new do
          include Hallon::Handler
          include handler if handler.is_a?(Module)
        end
      end
      
      klass.module_eval(&block) if block
      klass
    end
    
    # Returns the handlers’ associated session.
    # @return [Session]
    attr_reader :session

    # Associates the Handler with the given {Hallon::Session}.
    #
    # @param [Session] session
    def initialize(session)
      @session = session
    end
  end
end