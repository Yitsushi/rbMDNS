require "lib/mpc"

=begin rdoc
  ruby MPD-DBus Notify System
  ---
  This is a "GateWay" between MPD and DBUS...

  @author   Raito Yitsushi <yitsushi@gmail.com>
  @homepage http://yitsushi.github.com/rbMDNS/
  @source   http://github.com/Yitsushi/rbMDNS
  @issues   http://github.com/Yitsushi/rbMDNS/issues
=end
client = MDNS::MPC.new
client.start
