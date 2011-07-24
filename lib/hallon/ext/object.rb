# Extension of Object for Ruby 1.8 compatibility.
class Object
  unless method_defined?(:singleton_class)
    # Singleton class of object.
    def singleton_class
      class << self; self; end
    end
  end

  unless method_defined?(:define_singleton_method)
    # Defines a method on the singleton class of object.
    def define_singleton_method(*args, &b)
      singleton_class.send(:define_method, *args, &b)
    end
  end
end
