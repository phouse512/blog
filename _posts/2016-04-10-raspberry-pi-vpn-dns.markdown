---
layout: post
title: "Building Infrastructure with Raspberry Pi's"
date: 2016-04-10 12:30:31 -0600
categories: infrastructure raspberrypi
comments: true
---

With most of my programming projects, you could consider me a textbook
[yak-shaver][yak-shaver]. I usually find myself going down the rabbit hole so
much so that I end up wasting unnecessary time, but fortunately in this case
I ended up learning a lot of useful skills and knowledge. My original intention
was to start hosting my own graphite/carbon server so that I could set up
detailed metrics reporting for some of my applications. Up until now, I had
been using Digital Ocean for hosting my projects, but at $60/year I decided to
stomach the upfront cost of a (few) raspberry pi(s) and host one on my local apartment
network.

There were a few important design considerations given local area network
constraints that led me down a long trail of learning:

 - the graphite and carbon server need to be accessible from outside the router
 since a good deal of things are hosted outside of my personal network
 - from inside my network, devices should have human-readable host names, not
     just static ips

Since I wanted my instances hosted by digital ocean to be able to report to
graphite as well, outside servers would need some way to communicate to my
internal network. I'd read a bit about people hosting VPNs on their raspberry
pi's for securing their browsing, so I decided I'd go down that route, instead
of forwarding the graphite server's port to the internet world. Setting up
a VPN would also allow for remote troubleshooting versus having an address
I would blindly have to shoot packets into.

I decided to go with OpenVPN because of its ease of use and configurability.
There are dozens of guides you can use to actually get this setup so this won't be
a step-by-step guide, but a brief overview of the approach I took. Before
beginning to configure OpenVPN, I first had to setup a static IP address for my
pi so that the VPN port (1194 by default) could be forwarded through the
router. I set up the keys to use 2048-bit encryption because I'm paranoid and
the pi can handle it easily. Beware of the raspberry pi's iptable rules - I had
some issues that any of the setup guides didn't mention because my iptables
didn't have the proper interfaces forwarded (raspbian-jessie).

My ISP doesn't support static IP addresses, so I had to use a dynamic DNS
hosting service that gave me a free domain-name who's DNS server points to my
current ip. You can then run [DDclient][dd-client], a perl client that
auto-updates your dynamic DNS service provider's dns entry. Your
`ddclient.conf` can be pretty robust to handle almost any dynamic dns service
you choose. I also enabled logging and had it forward to `/var/log/openvpn.log`
for simpler debugging when I first was setting up. I can imagine somehow it
might be cool to add some monitoring around vpn stats in the future!






[yak-shaver]: http://urlgoeshere
[dd-client]: https://sourceforge.net/p/ddclient/wiki/Home/
