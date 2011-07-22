class Object
  unless defined?(singleton_class)
    def singleton_class
      class << self; self; end
    end
  end

  unless method_defined?(:define_singleton_method)
    def define_singleton_method(*args, &b)
      singleton_class.send(:define_method, *args, &b)
    end
  end
end
