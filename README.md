# Proproxy
Make faster to deploy your simple proxy server.

## Description
Proproxy installs squid into your server and sets firewall.
You can specify ip and port which can access your server though firewall.

## Links
- http://qiita.com

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'proproxy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install proproxy

## Usage

you need only 4 arguments.
- 1. your server ip
- 2. your server ssh port
- 3. your ip what accesses to proxy server
- 4. your port to use proxy server though firewall

```ruby
server = Proproxy::Server.new(:ubuntu, 'xxx.xxx.xxx.xxx', 22)
server.provision
server.update_ip_table('yyy.yyy.yyy.yyy', 33) # 33 is the port to use proxy server though firewall
```

`Proproxy::Server#initialize` method called, ssh access will start and connected your server.
`Proproxy::Server#provision` method installs squid into your server and sets `squid.conf` and `iptables` default setting.
`Proproxy::Server#update_ip_table` method sets your ip table settings.

### options

If you want to specify your ssh key path, or username
```ruby
server = Proproxy::Server.new(:ubuntu, 'xxx.xxx.xxx.xxx', 22, ssh_path: 'PATH_TO_YOUR_SSH_KEY', username: 'USERNAME')
```

Or your proxy server can be accessed `port 22` by default,
you can deny ssh access as:
```ruby
server.update_ip_table('yyy.yyy.yyy.yyy', 33, with_ssh_port: false)
```


You can control squid behavior from your local as:

```ruby
server.clear_squid_cache
server.stop_squid
server.start_squid
server.restart_squid
server.configure_ip_table # configures current ip settings
```

## Warning
Since I just released it, only `ubuntu 16.04` can be used.
If you missed your ip or ssh settings, the server can't be accessed eternally.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/100010/proproxy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

[MIT License](https://opensource.org/licenses/MIT).
