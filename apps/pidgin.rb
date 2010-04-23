require 'rubygems'
require 'dbus'

=begin rdoc
  MDNS::Pidgin
  ---
  Pidgin handler
  Connect Pidgin via DBus
=end
module MDNS
  class Pidgin
    def initialize
      bus = DBus::SessionBus.instance

      service = bus.service("im.pidgin.purple.PurpleService")
      @object  = service.object("/im/pidgin/purple/PurpleObject")
      @object.default_iface = 'im.pidgin.purple.PurpleInterface'

      @object.introspect
    end

    # set status message without changing the status
    def send(message)
      current = @object.PurpleSavedstatusGetType(@object.PurpleSavedstatusGetCurrent())
      status = @object.PurpleSavedstatusNew("", current)
      @object.PurpleSavedstatusSetMessage(status, message)
      @object.PurpleSavedstatusActivate(status)
    end
  end
end
