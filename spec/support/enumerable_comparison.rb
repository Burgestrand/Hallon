class Enumerator
  def ===(other)
    if other.is_a?(Enumerable)
      to_a == other.to_a
    else
      super
    end
  end
end
