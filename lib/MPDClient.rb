require 'rubygems'
require 'librmpd'
require 'lib/DBusKopete'

class MPDClient
  def initialize
    @dbus = DBusKopete.new
  end

  def state_callback( newstate )
    puts "MPD Changed State: #{newstate}"
    if newstate == 'stop'
      @dbus.send ''
    end
  end

  def current_callback( song )
    puts "MPD Changed Current Song: #{song.artist} - #{song.title}"
    @dbus.send "#{song.artist} - #{song.title}"
  end
end
