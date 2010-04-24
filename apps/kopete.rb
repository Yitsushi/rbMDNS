require 'rubygems'
require 'dbus'

=begin rdoc
  MDNS::Kopete
  ---
  Kopete handler
  Connect Kopete via DBus
=end
module MDNS
  class Kopete
    def initialize
      bus = DBus::SessionBus.instance

      service = bus.service("org.kde.kopete")
      @object  = service.object("/Kopete")
      @object.default_iface = 'org.kde.Kopete'

      @object.introspect
    end

    def send(message, status)
      @object.setIdentityOnlineStatus(status, "#{message}")
    end
  end
end
