module Hallon::Observable
  # Callbacks related to {Hallon::User::Post} objects.
  module Post
    # Includes {Hallon::Observable} for you.
    def self.extended(other)
      other.send(:include, Hallon::Observable)
    end

    protected

    # @return [Method] complete callback
    def initialize_callbacks
      callback_for(:complete)
    end

    # This callback is fired when the Image object is fully loaded.
    #
    # @example listening to this callback
    #   post = user.post(track)
    #   post.on(:complete) do
    #     puts "ze user be havin’ sum posts"
    #   end
    #
    # @yield []
    def complete_callback(pointer, userdata)
      trigger(pointer, :complete)
    end
  end
end
