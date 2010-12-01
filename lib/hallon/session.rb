require 'singleton'

module Hallon
  class Session
    attr_reader :appkey
    attr_reader :user_agent
    attr_reader :settings_path
    attr_reader :cache_path
    
    include Singleton
    def Session.instance(*args, &block)
      @__instance__ ||= new(*args, &block)
    end
  end
end