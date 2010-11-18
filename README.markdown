capistrano-rightscale
=================================================

Capistrano plugin for associating Rightscale tags with roles.

Introduction
============

[RightScale](http://www.rightscale.com) provides a service for managing deployments of servers in various clouds. Servers can be tagged with
machine tags. This plugin allows for specific tags in specific deployments to be mapped to Capistrano roles.

At present these mappings require several api calls, which are slow. On the first call, a cache file is written in the users
home directory. This can be disabled with an ENV variable RIGHTSCALE_CACHE=false.

Installation
============

`capistrano-rightscale` is provided as a Ruby gem, with the following dependencies:

* Capistrano >= 2.1.0
* Rightscale API

Usage
=====

In order to use the `capistrano-rightscale` plugin, you must require it in your Capfile:

	require 'capistrano/rightscale'

Then you must specify your Rightscale API credentials:

	set :rightscale_username, '???'
	set :rightscale_password, '???'
	set :rightscale_account, 12345

In order to define your roles, you defined the equivelent machine tags and deployment mappings:

	tag :webserver, "x99:role=app", :deployment => 45678

Credits
=======
* capistrano-ec2group: [Logan Raarup](http://github.com/logandk)
* capistrano: [Jamis Buck](http://github.com/jamis/capistrano)


Copyright (c) 2010 Lachlan Donald, released under the MIT license
