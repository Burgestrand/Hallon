RSpec.configure do
  def options
    {
      :user_agent => "Hallon (rspec)",
      :settings_path => "tmp",
      :cache_path => "tmp/cache"
    }
  end

  def session
    Hallon::Session.instance(Hallon::APPKEY, options)
  end
end
