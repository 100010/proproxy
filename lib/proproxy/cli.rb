require 'proproxy'
require 'thor'

module Proproxy
  class CLI < Thor
    desc "red WORD", "red words print."
    def red(word)
      say(word, :red)
    end

    desc 'provision proxy server', ''
    def set_up(server_name)
      # install squid, and apt-get update
    end

    desc 'add proxy server ip with port', ''
    def add_ip(server_name, ip, port)
      # edit iptables and save
      # configure ip tables
      # restart squid
    end

    desc 'remove specified ip from proxy server', ''
    def remove_ip(server_name, ip, port)
      # edit iptables and save
      # configure ip tables
      # restart squid
    end
  end
end
