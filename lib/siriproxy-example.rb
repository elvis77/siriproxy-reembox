# encoding: UTF-8
require 'cora'
require 'siri_objects'
require 'pp'
require 'socket'


class SiriProxy::Plugin::Reembox < SiriProxy::Plugin
  def initialize(config)
    @reembox_ip   = "192.168.101.153"
    @reembox_port = 2701

    @devices_on   = {'light one' => "rfm12 2272 0,21,17 76 3\n",
                    #'light two' => '',
                    }
    @devices_off  = {'light one' => "rfm12 2272 0,21,16 76 3\n",
                    #'light two' => '',
                    }
  end

  def send_message(device, cmd)
    client = TCPSocket.open(@reembox_ip, @reembox_port)
    request = ""
    begin
    case cmd
      when "on"
        request = @devices_on[device]
        if !request.nil?
          say "Turning on " + device + "."
        end
      when "off"
        request = @devices_off[device]
        if !request.nil?
          say "Turning off " + device + "."
        end
      else
        say "I do not understand you."
    end
    end
    if request.nil?
      say "This device is not configured."
    else
      client.write(request)
      client.close
    end
  end


  # Listener for turning on the light
  listen_for /(light one|light two).*(on|off)/i do |device, cmd|
      send_message(device, cmd)
  end
  listen_for /(on|off).*(light one|light two)/i do |cmd, device|
      send_message(device, cmd)
  end
end
