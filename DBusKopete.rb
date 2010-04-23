require 'rubygems'
require 'dbus'

class DBusKopete
  def initialize
    bus = DBus::SessionBus.instance

    service = bus.service("org.kde.kopete")
    @object  = service.object("/Kopete")
    @object.default_iface = 'org.kde.Kopete'

    @object.introspect
  end

  def send(message)
    @object.setIdentityOnlineStatus("Online", message)
  end
end
