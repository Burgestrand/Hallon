# coding: utf-8
describe Hallon::Observable::Session do
  let(:klass) { Class.new { include described_class } }
  let(:object) { klass.new }

  it { should include Hallon::Observable }

  specification_for_callback "logged_in" do
    let(:input)  { [a_pointer, :ok] }
    let(:output) { [:ok, subject] }
  end

  specification_for_callback "logged_out" do
    let(:input)  { [a_pointer] }
    let(:output) { [subject] }
  end

  specification_for_callback "metadata_updated" do
    let(:input)  { [a_pointer] }
    let(:output) { [subject] }
  end

  specification_for_callback "connection_error" do
    let(:input)  { [a_pointer, :ok] }
    let(:output) { [:ok, subject] }
  end

  specification_for_callback "message_to_user" do
    let(:input)  { [a_pointer, "ALL UR BASE"] }
    let(:output) { ["ALL UR BASE", subject] }
  end

  specification_for_callback "notify_main_thread" do
    let(:input)  { [a_pointer] }
    let(:output) { [subject] }
  end

  specification_for_callback "music_delivery", :pending do
    let(:input)  { [a_pointer] }
    let(:output) { [subject] }

    it "should return the resulting value" do
      subject.on(:music_delivery) { 7 }
      subject.callback_for(:music_delivery).call(*input).should eq 7
    end
  end

  specification_for_callback "play_token_lost" do
    let(:input)  { [a_pointer] }
    let(:output) { [subject] }
  end

  specification_for_callback "end_of_track" do
    let(:input)  { [a_pointer] }
    let(:output) { [subject] }
  end

  specification_for_callback "start_playback" do
    let(:input)  { [a_pointer] }
    let(:output) { [subject] }
  end

  specification_for_callback "stop_playback" do
    let(:input)  { [a_pointer] }
    let(:output) { [subject] }
  end

  specification_for_callback "get_audio_buffer_stats" do
    let(:input)  { [a_pointer, Spotify::AudioBufferStats.new.pointer] }
    let(:output) { [subject] }

    it "should return the resulting audio buffer stats" do
      stats = Spotify::AudioBufferStats.new
      subject.on(:get_audio_buffer_stats) { [5, 7] }

      stats[:samples].should eq 0
      stats[:stutter].should eq 0
      subject.callback_for(:get_audio_buffer_stats).call(a_pointer, stats.pointer)
      stats[:samples].should eq 5
      stats[:stutter].should eq 7
    end

    it "should report zeroes if there’s no callback" do
      stats = Spotify::AudioBufferStats.new

      stats[:samples].should eq 0
      stats[:stutter].should eq 0
      subject.callback_for(:get_audio_buffer_stats).call(a_pointer, stats.pointer)
      stats[:samples].should eq 0
      stats[:stutter].should eq 0
    end
  end

  specification_for_callback "streaming_error" do
    let(:input)  { [a_pointer, :ok] }
    let(:output) { [:ok, subject] }
  end

  specification_for_callback "userinfo_updated" do
    let(:input)  { [a_pointer] }
    let(:output) { [subject] }
  end

  specification_for_callback "log_message" do
    let(:input)  { [a_pointer, "WATCHING U!"] }
    let(:output) { ["WATCHING U!", subject] }
  end

  specification_for_callback "offline_status_updated" do
    let(:input)  { [a_pointer] }
    let(:output) { [subject] }
  end

  specification_for_callback "offline_error" do
    let(:input)  { [a_pointer, :ok] }
    let(:output) { [:ok, subject] }
  end
end
