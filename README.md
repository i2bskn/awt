# Awt

[![Gem Version](https://badge.fury.io/rb/awt.png)](http://badge.fury.io/rb/awt)
[![Build Status](https://travis-ci.org/i2bskn/awt.png)](https://travis-ci.org/i2bskn/awt)
[![Coverage Status](https://coveralls.io/repos/i2bskn/awt/badge.png)](https://coveralls.io/r/i2bskn/awt)
[![Code Climate](https://codeclimate.com/github/i2bskn/awt.png)](https://codeclimate.com/github/i2bskn/awt)

Awt is cli tool for system administration.

## Requirements

* Ruby 2.0.0

## Installation

Add this line to your application's Gemfile:

    gem 'awt'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install awt

## Usage

Awt to run looking Awtfile from a task that is specified in the argument.

#### Awtfile

Awtfile be placed in the home directory or the current directory tree.  
It can be specified on the command line if you want to place other location.

`server` can also be specified on the command line argument.  
`server` required if you do not specify on the command line argument.

The following example of Awtfile.

```ruby
server "hostname", user: "awt", port: 22, key: "/path/to/id_rsa"

task :task_name do
  run "do something"
  put "/path/to/local/file", "/path/to/remote/file"
  get "/path/to/remote/file", "/path/to/local/file"
end
```

`run` is returns a result object.  
Result object with a exit-status, etc.

```ruby
if run("cat /etc/centos-release").status == 0
  puts "Hello CentOS"
end

if run("uname -a").data.chomp == "Linux"
  puts "Hello Linux"
end
```

#### Execute

Awt task executable as follows:

```
$ bundle exec awt task_name
```

Options that can be specified:

* `-H host1,host2` => Required if you do not specify on the command line argument.
* `-u user` => Specify user name. Default is current user name.
* `-p port` => Specify port number. Default is 22.
* `-i identity_file` => Specify identity file. Default is `~/.ssh/id_rsa`.
* `-f file` => `/path/to/Autfile`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
