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
    def send(message, tmp)
      current = @object.PurpleSavedstatusGetType(@object.PurpleSavedstatusGetCurrent()[0])[0]
      status = @object.PurpleSavedstatusNew("", current)[0]
      @object.PurpleSavedstatusSetMessage(status, message)
      @object.PurpleSavedstatusActivate(status)
    end
  end
end
