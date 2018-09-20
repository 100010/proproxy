require "proproxy/version"
require 'pry'
require 'sshkit'
class InvalidServerNameError < StandardError ; end

class Server
  AVAILABLE_OS_NAME = [
    :ubuntu,
    :centos
  ]

  include SSHKit::DSL

  def initialize(os_name, ip, port, options={})
    unless AVAILABLE_OS_NAME.include? os_name
      raise InvalidServerNameError.new 'invalid os name'
    end

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
  end

  def update_ip_table
  end

  def stop_squid
  end

  def start_squid
  end

  def clear_squid_cache
  end
end
