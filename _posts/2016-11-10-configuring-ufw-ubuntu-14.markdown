---
layout: post
title: "Setting up firewalls on Ubuntu 14.04 with UFW"
date: 2016-11-10 05:34:00 -0600
categories: linux cloud ssh security
comments: true
---

Firewalls. They can be confusing, mystifying, and annoying especially when you're trying
to get a game set up for a LAN party. Today we're going to look into how
firewalls can be used to block potentially dangerous external traffic on your
Ubuntu instance.

At the core of packet filtering in Ubuntu lies a program called
[iptables][iptable]. `iptables` is incredibly configurable, but it's often
easier to be dangerous rather than effective at the beginning. Fortunately
for you, there is a utility named `ufw` that wraps around `iptables` to make it
easier to understand and modify. Its name is an acronym for Uncomplicated
FireWall, but most refer to it as `ufw`.  While `ufw` is not responsible for actually
blocking packets (`iptables` still is), it simplifies the commands needed to
manipulate `iptables` for you. The following diagram explains how the utilities
work together to help filter out unnecessary traffic.


![diagram here boi][test]:

#### Configuration
`ufw` truly lives up to its name and is incredibly easy to set as we'll see in
just a bit. First, let's check the status of your firewall by running the
following:

`sudo ufw status`

More likely then not, it will you that it is inactive. If it is active, it will
give you a list of the current firewall rules that we'll go over soon. In the
rare case that `ufw` is not already installed on your machine, run the
following and you'll be golden:

`sudo apt-get install ufw`

##### Supporting IPv6
Your machine is most likely configured to support IPv6, so let's make sure that
`ufw` can handle it too. Open the configuration file like this: 

`sudo vim /etc/default/ufw`

In that file, search for the line beginning with IPV6 and make sure the config
line looks like this:

`IPV6=yes`

From there, you only need to restart ufw by running `sudo ufw disable` and
`sudo ufw enable`.

#### Setting Firewall Rules
Now that UFW is up and running, it's time to set up the rules for internet
traffic. It's better to deny _all_ incoming traffic by default, and slowly open up ports
as necessary so that you consciously choose your [attack vectors][attack].
Luckily this is the default for UFW, so there is no work to do here. If you are
curious, this is the command to deny all incoming packets:

`sudo ufw default deny incoming`

Next, we want to start enabling certain connections 


[iptable]: https://en.wikipedia.org/wiki/Iptables
[attack]: http://searchsecurity.techtarget.com/definition/attack-vector
