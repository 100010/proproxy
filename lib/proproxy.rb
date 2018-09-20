require "proproxy/version"
require "proproxy/cli"
require 'pry'
require 'sshkit'

class InvalidServerNameError < StandardError ; end

module Proproxy
  class Server
    AVAILABLE_OS_NAME = [
      :ubuntu,
      :centos
    ]

    include SSHKit::DSL

    def initialize(os_name, ip, port, options={})
      # TODO: enable to choose even if the server is not ubuntu
      # unless AVAILABLE_OS_NAME.include? os_name
      #   raise InvalidServerNameError.new 'invalid os name'
      # end

      if options[:ssh_path].nil?
        @ssh_path = '~/.ssh/id_rsa'
      else
        @ssh_path = options[:ssh_path]
      end

      if options[:username].nil?
        @username = 'root'
      else
        @username = options[:username]
      end

      SSHKit.config.output_verbosity = Logger::DEBUG

      @remote_host = SSHKit::Host.new(ip)
      @remote_host.user = @username
      @remote_host.ssh_options = {
        keys: [@ssh_path],
        auth_methods: %w(publickey)
      }
    end

    def provision
      on @remote_host do
        execute 'sudo apt-get update -y'
        execute 'sudo apt-get install squid -y'
        execute 'mkdir /etc/sysconfig/'
        execute 'touch /etc/sysconfig/iptables'
      end
    end

    def restart_squid
      stop_squid
      start_squid
    end

    def update_ip_table(ip_v4, port)
      new_tonnel = "-A FWINPUT -p tcp -m tcp --dport #{port} -s #{ip_v4} -j ACCEPT"
      on @remote_host do
        execute "echo #{new_tonnel} >> /etc/sysconfig/iptables"
      end
      configure_ip_table
      restart_squid
    end

    def configure_ip_table
      on @remote_host do
        execute 'iptables-restore < /etc/sysconfig/iptables'
      end
    end

    def stop_squid
      on @remote_host do
        execute 'service squid stop'
      end
    end

    def start_squid
      on @remote_host do
        execute 'service squid start'
      end
    end

    def clear_squid_cache
      on @remote_host do
        execute 'squid -z'
      end
    end
  end
end
