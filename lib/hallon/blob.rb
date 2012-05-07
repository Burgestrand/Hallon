module Hallon
  # Dummy module, allows for infecting strings
  # with a Hallon::Blob to check for if they are
  # blobs or not.
  module Blob
  end

  def self.Blob(string)
    string.extend(Blob)
  end
end
