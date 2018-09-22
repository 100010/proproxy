require "proproxy/version"
require 'pry'
require 'sshkit'

class InvalidServerNameError < StandardError ; end

module Proproxy
  class Server
    # TODO:
    # AVAILABLE_OS_NAME = [
    #   :ubuntu,
    #   :centos
    # ]

    include SSHKit::DSL

    def initialize(os_name, ip, port, options={})
      # TODO: enable to choose even if the server is not ubuntu
      # unless AVAILABLE_OS_NAME.include? os_name
      #   raise InvalidServerNameError.new 'invalid os name'
      # end

      ssh_path = if options[:ssh_path].nil?
        '~/.ssh/id_rsa'
      else
        options[:ssh_path]
      end

      username = if options[:username].nil?
        'root'
      else
        options[:username]
      end

      SSHKit.config.output_verbosity = Logger::DEBUG

      @remote_host = SSHKit::Host.new(ip)
      @remote_host.user = username
      @remote_host.ssh_options = {
        keys: [ ssh_path ],
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
      copy_template
    end

    def restart_squid
      stop_squid
      start_squid
    end

    def update_ip_table(ip_v4, port, with_ssh_port: true)
      new_tonnel = "-A FWINPUT -p tcp -m tcp --dport #{port} -s #{ip_v4} -j ACCEPT"
      new_port = "http_port #{port}"
      new_src = "acl myacl src #{ip_v4}/255.255.255.255"

      remove_last_2_line
      on @remote_host do
        execute "echo #{new_tonnel} >> /etc/sysconfig/iptables"
        execute "echo #{new_port} >> /etc/squid/squid.conf"
        execute "echo #{new_src} >> /etc/squid/squid.conf"
      end
      add_icmp_host_prohibited_line
      add_last_commit_line_command

      if with_ssh_port
        ssh_tonnel = "-A FWINPUT -p tcp -m tcp --dport 22 -s #{ip_v4} -j ACCEPT"
        ssh_port = "http_port 22"
        remove_last_2_line
        on @remote_host do
          execute "echo #{ssh_tonnel} >> /etc/sysconfig/iptables"
          execute "echo #{ssh_port} >> /etc/squid/squid.conf"
        end
        add_icmp_host_prohibited_line
        add_last_commit_line_command
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

    private

    def remove_last_2_line
      on @remote_host do
        execute 'head -n -2 /etc/sysconfig/iptables > /etc/sysconfig/tmp_iptables ; mv /etc/sysconfig/tmp_iptables /etc/sysconfig/iptables'
      end
    end

    def add_last_commit_line_command
      on @remote_host do
        execute 'echo COMMIT >> /etc/sysconfig/iptables'
      end
    end

    def add_icmp_host_prohibited_line
      on @remote_host do
        execute 'echo -A FWINPUT -j REJECT --reject-with icmp-host-prohibited >> /etc/sysconfig/iptables'
      end
    end

    def copy_template
      file_path = File.dirname(__FILE__).gsub('/lib', '')
      on @remote_host do
        upload! "#{file_path}/templates/iptables", '/etc/sysconfig/iptables'
        upload! "#{file_path}/templates/squid.conf", '/etc/squid/squid.conf'
      end
    end
  end
end
