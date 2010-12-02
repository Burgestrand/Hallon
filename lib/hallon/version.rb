module Hallon
  # Current release version of Hallon
  #
  # @see http://semver.org/
  module Version
    # Incremented *only* on backwards **incompatible** changes.
    MAJOR  = 0
    
    # Incremented *only* after adding new, backwards compatible functionality.
    MINOR  = 0
    
    # Incremented *only* on backwards compatible bug fixes.
    PATCH  = 0
    
    # String representation of the current version in the form X.Y.Z
    STRING = "#{MAJOR}.#{MINOR}.#{PATCH}"
  end
end