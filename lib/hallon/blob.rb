module Hallon
  # Dummy module, allows for infecting strings
  # with a Hallon::Blob to check for if they are
  # blobs or not.
  module Blob
  end

  # Used to mark strings as Hallon::Blob for Session#login.
  #
  # @example creating a string blob
  #    blob = Hallon::Blob("this is now a blob")
  #
  # @return [String<Hallon::Blob>] a string that is now a Blob
  def self.Blob(string)
    string.extend(Blob)
  end
end
