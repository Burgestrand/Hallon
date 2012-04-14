# coding: utf-8
describe Hallon::Observable::Session do
  let(:klass) { Class.new { include described_class } }
  let(:object) { klass.new }

  specification_for_callback "logged_in" do
    let(:input)  { [a_pointer, :ok] }
    let(:output) { [:ok] }
  end

  specification_for_callback "logged_out" do
    let(:input)  { [a_pointer] }
    let(:output) { [] }
  end

  specification_for_callback "metadata_updated" do
    let(:input)  { [a_pointer] }
    let(:output) { [] }
  end

  specification_for_callback "connection_error" do
    let(:input)  { [a_pointer, :ok] }
    let(:output) { [:ok] }
  end

  specification_for_callback "message_to_user" do
    let(:input)  { [a_pointer, "ALL UR BASE"] }
    let(:output) { ["ALL UR BASE"] }
  end

  specification_for_callback "notify_main_thread" do
    let(:input)  { [a_pointer] }
    let(:output) { [] }
  end

  specification_for_callback "music_delivery" do
    let(:num_frames) do
      data.size / 2
    end

    let(:data) do
      (0...100).zip((0...100).to_a.reverse).flatten # [0, 99, 1, 98 …]
    end

    let(:frames) do
      channels = 2
      frames = FFI::MemoryPointer.new(:int16, num_frames * channels)
      frames.write_array_of_int16(data.flatten)
      frames
    end

    let(:format) do
      struct = Spotify::AudioFormat.new
      struct[:sample_type] = :int16
      struct[:sample_rate] = 44100 # 44.1khz
      struct[:channels]    = 2
      struct.pointer
    end

    let(:input)  { [a_pointer, format, frames, num_frames] }
    let(:output) { [{rate: 44100, type: :int16, channels: 2}, data.each_slice(2)] }

    it "should return the resulting value" do
      subject.on(:music_delivery) { 7 }
      subject_callback.call(*input).should eq 7
    end

    it "should ensure the resulting value is an integer" do
      subject_callback.call(*input).should eq 0
    end

    it "should not go ballistic when there is no audio data" do
      subject_callback.call(a_pointer, format, FFI::Pointer::NULL, 0)
    end
  end

  specification_for_callback "play_token_lost" do
    let(:input)  { [a_pointer] }
    let(:output) { [] }
  end

  specification_for_callback "end_of_track" do
    let(:input)  { [a_pointer] }
    let(:output) { [] }
  end

  specification_for_callback "start_playback" do
    let(:input)  { [a_pointer] }
    let(:output) { [] }
  end

  specification_for_callback "stop_playback" do
    let(:input)  { [a_pointer] }
    let(:output) { [] }
  end

  specification_for_callback "get_audio_buffer_stats" do
    let(:input)  { [a_pointer, Spotify::AudioBufferStats.new.pointer] }
    let(:output) { [] }

    it "should return the resulting audio buffer stats" do
      stats = Spotify::AudioBufferStats.new
      subject.on(:get_audio_buffer_stats) { [5, 7] }

      stats[:samples].should eq 0
      stats[:stutter].should eq 0
      subject_callback.call(a_pointer, stats.pointer)
      stats[:samples].should eq 5
      stats[:stutter].should eq 7
    end

    it "should report zeroes if there’s no callback" do
      stats = Spotify::AudioBufferStats.new

      stats[:samples].should eq 0
      stats[:stutter].should eq 0
      subject_callback.call(a_pointer, stats.pointer)
      stats[:samples].should eq 0
      stats[:stutter].should eq 0
    end
  end

  specification_for_callback "streaming_error" do
    let(:input)  { [a_pointer, :ok] }
    let(:output) { [:ok] }
  end

  specification_for_callback "userinfo_updated" do
    let(:input)  { [a_pointer] }
    let(:output) { [] }
  end

  specification_for_callback "log_message" do
    let(:input)  { [a_pointer, "WATCHING U!"] }
    let(:output) { ["WATCHING U!"] }
  end

  specification_for_callback "offline_status_updated" do
    let(:input)  { [a_pointer] }
    let(:output) { [] }
  end

  specification_for_callback "offline_error" do
    let(:input)  { [a_pointer, :ok] }
    let(:output) { [:ok] }
  end
end
