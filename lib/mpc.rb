require 'rubygems'
require 'librmpd'
require "lib/config_loader"

=begin rdoc
  MDNS::MPC
  ---
  Connect to Music Player Daemon
  Register callback functions to 
    - Change status [play, stop, pause] (MPD::STATE_CALLBACK)
    - Change song (MPD::CURRENT_SONG_CALLBACK)
  if MPD::STATE_CALLBACK equal stop
    then send empty string to applications
  if MPD::CURRENT_SONG_CALLBACK
    then send artist and title of the current song to applications
=end
module MDNS
  class MPC
    include ConfigLoader
    def initialize
      load_config

      @applications = []

      load_application_handlers

      @mpd = MPD.new(
        @config['mpd']['host'],
        @config['mpd']['port'].to_i
      )
      @mpd.connect(true)

      set_listeners
    end

    def start
      while true
        sleep 1
      end
      @mpd.disconnect
    end

    # callback functions
    def state_callback( newstate )
      if newstate == 'stop'
        send_to_all('')
      end
    end

    def current_callback( song )
      send_to_all("#{song.artist} - #{song.title}")
    end

    # Private functions
    private
    def load_application_handlers
      @config['applications'].each do |app|
        require "apps/#{app}"
        @applications.push(eval("#{app.capitalize}.new()"))
      end
    end

    # send 'message' to applications
    def send_to_all(message)
      puts message if message
      @applications.each do |app|
        app.send(message)
      end
    end

    def set_listeners
      state_cb = self.method 'state_callback'
      @mpd.register_callback(state_cb,  MPD::STATE_CALLBACK)

      current_cb = self.method 'current_callback'
      @mpd.register_callback(current_cb, MPD::CURRENT_SONG_CALLBACK)
    end
  end
end
