class AudioDriverMock
  attr_reader :state

  # Expected implementation:
  attr_accessor :format

  def stream(&block)
    @stream = block if block_given?
    @stream
  end

  def play
    @state = :play
  end

  def pause
    @state = :pause
  end

  def stop
    @state = :stop
  end
end
