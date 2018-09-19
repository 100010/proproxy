require "proproxy/version"
require "proproxy/cli"
require 'pry'

module Proproxy
  class CLI < ::Thor
    desc 'provision proxy server'
    def set_up(server_name)
      # install squid, and apt-get update
    end

    desc 'add proxy server ip with port'
    def add_ip(server_name, ip, port)
      # edit iptables and save
      # configure ip tables
      # restart squid
    end

    desc 'remove specified ip from proxy server'
    def remove_ip(server_name, ip, port)
      # edit iptables and save
      # configure ip tables
      # restart squid
    end
  end
end
