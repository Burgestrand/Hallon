# coding: utf-8

# Extensions to the Spotify gem.
#
# @see https://github.com/Burgestrand/spotify
module Spotify
  # Makes it easier binding callbacks safely to callback structs.
  #
  # @see add
  # @see remove
  module CallbackStruct
    # Before assigning [member]=(callback), inspect the arity of
    # said callback and raise an ArgumentError if they don‘t match.
    #
    # @raise ArgumentError if the arity of the given callback does not match the member
    def []=(member, callback)
      unless callback.arity < 0 or callback.arity == arity_of(member)
        raise ArgumentError, "#{member} callback takes #{arity_of(member)} arguments, was #{callback.arity}"
      else
        super
      end
    end

    protected

    # @param [Symbol] member
    # @return [Integer] arity of the given callback member
    def arity_of(member)
      fn = layout[member].type
      fn.param_types.size
    end
  end

  SessionCallbacks.instance_eval do
    include CallbackStruct
  end

  PlaylistCallbacks.instance_eval do
    include CallbackStruct
  end

  PlaylistContainerCallbacks.instance_eval do
    include CallbackStruct
  end
end
