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

      @listeners_ok = false
      @first_run = true
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
      @state = newstate
      if newstate == 'play'
        current_callback(nil)
      end
      if newstate == 'stop'
        send_to_all(
          @config['message']['state']['stop']['text'],
          @config['message']['state']['stop']['status']
        )
      end
    end

    def current_callback( song )
      return if @state == 'stop'
      song = @mpd.current_song if song.nil?

      send_to_all(
        generate_satus_message_with_format(song),
        @config['message']['song']['status']
      )
      puts "D: " + generate_satus_message_with_format(song)
    end

    def playlist_callback( playlist )
      puts "Playlist Change #{playlist}"
    end

    def time_callback( second, full )
      puts "Time Change #{second}/#{full}"
    end

    def volume_callback( volume )
      puts "Volume Change #{volume}"
    end

    def repeat_callback( repeat )
      puts "Repeat Change #{repeat}"
    end
    
    def random_callback( random )
      puts "Random Change #{random}"
    end

    def playlist_length_callback( pl_length )
      puts "Playlist Length Change #{pl_length}"
    end
    
    def crossfade_callback( crossfade )
      puts "Crossfade Change #{crossfade}"
    end

    def connection_callback( connection )
      puts "Connection Change #{connection}"
      puts "#{@first_run} #{connection}"
      if @first_run and connection
#       @mpd.register_callback(self.method('time_callback'),  MPD::TIME_CALLBACK)
        @mpd.register_callback(self.method('volume_callback'),  MPD::VOLUME_CALLBACK)
      end

      if not connection
        @mpd.connect(true)
        # set_listeners
      end
      @first_run = false
    end

    # Private functions
    private
    def load_application_handlers
      @config['applications'].each do |app|
        require "apps/#{app}"
        @applications.push(eval("#{app.capitalize}.new()"))
      end
    end

    def generate_satus_message_with_format(song)
      format = @config['message']['song']['format']
      format.
        gsub(/\$\{artist\}/, (song.artist.nil? ? "[no artist]" : song.artist) ).
        gsub(/\$\{title\}/,  (song.title.nil? ? "[no title]" : song.title) ).
        gsub(/\$\{album\}/,  (song.album.nil? ? "[no album]" : song.album) )
    end

    # send 'message' to applications
    def send_to_all(message, status)
      puts message if message
      @applications.each do |app|
        app.send(message, status)
      end
    end

    def set_listeners
      @mpd.register_callback(self.method('current_callback'), MPD::CURRENT_SONG_CALLBACK)
      @mpd.register_callback(self.method('state_callback'),  MPD::STATE_CALLBACK)
      @mpd.register_callback(self.method('playlist_callback'),  MPD::PLAYLIST_CALLBACK)

      @mpd.register_callback(self.method('repeat_callback'),  MPD::REPEAT_CALLBACK)
      @mpd.register_callback(self.method('random_callback'),  MPD::RANDOM_CALLBACK)
      @mpd.register_callback(self.method('playlist_length_callback'),  MPD::PLAYLIST_LENGTH_CALLBACK)
      @mpd.register_callback(self.method('crossfade_callback'),  MPD::CROSSFADE_CALLBACK)
      @mpd.register_callback(self.method('connection_callback'),  MPD::CONNECTION_CALLBACK)

      @listeners_ok = false
    end
  end
end
