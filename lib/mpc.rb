require 'rubygems'
require 'librmpd'
require "lib/config_loader"

module MDNS
  class MPC
    include ConfigLoader
    def initialize
      load_config

      @applications = []

      load_application_handlers

      @mpd = MPD.new('localhost', 6600)
      @mpd.connect(true)

      set_listeners
    end

    def start
      while true
        sleep 1
      end
      @mpd.disconnect
    end

    def state_callback( newstate )
      if newstate == 'stop'
        send_to_all('')
      end
    end

    def current_callback( song )
      send_to_all("#{song.artist} - #{song.title}")
    end

    private
    def load_application_handlers
      @config['applications'].each do |app|
        require "apps/#{app}"
        @applications.push(eval("#{app.capitalize}.new()"))
      end
    end

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
