require "lib/MPDClient"

begin
  mpd = MPD.new 'localhost', 6600
  mpd.connect true

  client = MPDClient.new

  state_cb   = client.method 'state_callback'
  mpd.register_callback state_cb,  MPD::STATE_CALLBACK

  current_cb = client.method 'current_callback'
  mpd.register_callback current_cb, MPD::CURRENT_SONG_CALLBACK

  while true:
    sleep 1
  end
rescue
  mpd.disconnect
end
