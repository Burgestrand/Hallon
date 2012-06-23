# coding: utf-8
require 'timeout'

describe Hallon::AudioQueue do
  let(:queue) { Hallon::AudioQueue.new(4) }
  let(:format) { { :rate => 44100, :channels => 2, :type => :int16 } }
  subject { queue }

  it "should conform to “filling the buffer” example" do
    format = {:rate => 44100, :channels => 2, :type => :int16}
    queue.push(format, [1, 2]).should eq 2
    queue.push(format, [3]).should eq 1
    queue.push(format, [4, 5, 6]).should eq 1
    queue.push(format, [5, 6]).should eq 0
    queue.pop(format, 1).should eq [1]
    queue.push(format, [5, 6]).should eq 1
    queue.pop(format).should eq [2, 3, 4, 5]
  end

  it "should conform to the “changing the format” example" do
    queue  = Hallon::AudioQueue.new(4)
    queue.format.should eq nil
    queue.push(:initial_format, [1, 2, 3, 4, 5]).should eq 4
    queue.size.should eq 4
    queue.format.should eq :initial_format
    queue.push(:new_format, [1, 2]).should eq 2
    queue.size.should eq 2
    queue.format.should eq :new_format
  end

  describe "#pop" do
    it "should not block if the queue is not empty" do
      queue.push(format, [1, 2])

      start = Time.now
      queue.pop(format).should eq [1, 2]
      (Time.now - start).should be_within(0.001).of(0)
    end

    it "should block if the queue is empty" do
      queue.size.should be_zero

      # I could mock out ConditionVariable and Mutex, but where’s the fun in that?
      start = Time.now
      Thread.start { sleep 0.2; queue.push(format, [1]) }
      queue.pop(format).should eq [1]
      (Time.now - start).should be_within(0.08).of(0.2)
    end

    it "returns does nothing if the format does not match" do
      queue.push(:one_format, [1, 2, 3, 4])
      queue.pop(:another_format).should eq nil
      queue.pop(:one_format).should eq [1, 2, 3, 4]
    end
  end

  describe "#clear" do
    it "should clear the queue" do
      queue.push(format, [1, 2])
      queue.should_not be_empty
      queue.clear
      queue.should be_empty
    end
  end

  describe "#format" do
    it "is determined by the format of the audio samples" do
      queue.push(:one_format, [1, 2, 3])
      queue.format.should eq :one_format
      queue.push(:another_format, [4, 5, 6])
      queue.format.should eq :another_format
    end
  end

  describe "#synchronize" do
    it "should be re-entrant" do
      expect { queue.synchronize { queue.synchronize {} } }.to_not raise_error
    end
  end

  describe "#new_cond" do
    it "should be bound to the queue" do
      condvar = queue.new_cond
      inside  = false

      Thread.new(queue, condvar) do |q, c|
        q.synchronize do
          inside = true
          c.signal
        end
      end

      Timeout::timeout(1) do
        queue.synchronize do
          condvar.wait_until { inside }
        end
      end

      inside.should be_true
    end
  end
end
