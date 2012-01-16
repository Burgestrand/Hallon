# coding: utf-8
require 'monitor'

begin
  require 'coreaudio'
rescue LoadError
  abort <<-ERROR
    This example requires the ruby-coreaudio gem.

    See: http://rubygems.org/gems/coreaudio
  ERROR
end

puts <<-INFO
  Keep in mind, you’re now using the CoreAudio driver, part
  of Hallon examples. This driver does not buffer data, so
  even the slightest hickup in Ruby will make the playback
  stutter. The reason is that this CoreAudio driver does not
  buffer data internally.
INFO

module Hallon
  class CoreAudio
    attr_reader :output
    protected :output

    def initialize(format)
      @device = ::CoreAudio.default_output_device
      @output = @device.output_buffer(format[:rate] * 3)
      @format = format
    end

    attr_accessor :format

    def stream
      loop { output << yield }
    end

    def play
      output.start
    end

    def stop
      output.stop
    end

    def pause
      output.stop
    end
  end
end
