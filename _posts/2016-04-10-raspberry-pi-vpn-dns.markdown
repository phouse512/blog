---
layout: post
title: "Building Infrastructure with Raspberry Pi's"
date: 2016-04-10 12:30:31 -0600
categories: infrastructure raspberrypi
comments: true
---

With most of my programming projects, you could consider me a textbook
[yak-shaver][yak-shaver]. I usually find myself going down the rabbit hole so
much so that I end up wasting unnecessary time and energy, but fortunately in this case
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
you choose. OpenVPN also has some useful logging you can use to debug your VPN when setting up - in the future if (when..?) I build a log aggregation service using syslog. It might also come in handy for adding some metrics monitoring about usage and data passed through.

#### DNS and DHCP Server

Next, I realized I wasn't able to connect to devices via hostname, only with IPs. Handling hostname resolution in local `/etc/hosts` wasn't a path I wanted to go down, especially since I have multiple computers. The next logical step: host my own DNS server on an extra raspberry 
pi in my own apartment.

The netgear router in my apartment allows for you to specify custom DNS servers, so I could easily test out my server. After some searching and reading, using dnsmasq seemed like the best fit for my relatively lightweight needs. The documentation and man page around it is very helpful, so I won't explain too much here. Some configuration things to note: 1) set up specific logging for this service in its own directory - seeing your DNS server actually cache/process hostname resolution is useful in the beginning, but they are also incredibly chatty. Putting it in its own file will make it easier to set up log rotation, and can give you the opportunity to see how effective your DNS server is, similarly to how [pi-hole][pi-hole] does it. 2) set your fallback DNS servers to something reliable and fast- if you're in the continental U.S. I would recommend using Google's at 8.8.8.8 or 8.8.4.4.

#### Outage #1

2 days into my home installation, my internet stopped working, and I was no longer able to connect on the VPN to my home network. When I physically able to see that the raspberry pi's were on, but something was keeping them from operating normally. After a little more digging, I realized I had forgotten that I had set the raspberry pi's static ip addresses through the router, but the router's dhcp server was no longer running and saving those ip's.

From what I can tell: 1) someone accidentally unplugged the raspberry pi's but realized and plugged them back in. 2) because the pi's didn't have static ip addresses, when they connected (via Ethernet) they grabbed whatever ips they could. 3) The router had my DNS server's ip hard coded, so when the pi's changed, a device could no longer resolve hostnames. 4) the port forwarded for the vpn also pointed at a static address so outside connections couldn't resolve either. 5) Not only were existing devices not able to connect to the Internet, new devices could also not connect without manually specifying an ip and trying (most devices use DHCP by default).

All-in-all, it was a pretty big mess, and there are still a few unanswered questions about why things turned out the way they did. I'm still not sure how a local network resolves the location of the DHCP server if the router dhcp is turned off, and subnets are still a black-hole to me but I learned from my mistakes and know a little more about running your own little sliver of the Internet.

Now..time to work on that Graphite server!


[yak-shaver]: http://urlgoeshere
[dd-client]: https://sourceforge.net/p/ddclient/wiki/Home/
[pi-hole]: http://linkyk
