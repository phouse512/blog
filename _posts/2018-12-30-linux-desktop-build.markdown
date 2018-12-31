---
layout: post
title: "Building a Desktop Linux PC"
date: 2018-12-30 12:00:00 -0600
categories: linux diy build
comments: true
---

For the past 7 years, I've almost exclusively lived off 3 different laptops
that I've owned. Between the three of them, I've used one Windows 7 machine,
and two OSX laptops. The OSX laptops have been the most reliable and common
ones that I've used for development the past 5 years. The Windows laptop died
a few years into usage and I haven't touched it since. In the meantime, I've
wanted to work on getting a home network setup with NAS and various other
utilities. To set all that up, a Linux home base has been a prerequisite for
a while. Over the holidays, I found some good deals on some parts I've been
waiting for, so I decided to spring on it.

1. [goals](#goals)
2. [the build](#the-build)
    1. [parts list](#parts-list)
    2. [order of operations](#order-of-operations)
    3. [linux install](#linux-install)
    4. [lessons learned](#lessons-learned)
3. [stability and burn-in](#3)
4. [configuration management](#4)
5. [backup and storage](#5)


## goals

This desktop build is meant to satisfy a relatively narrow set of use-cases. My
parts list and setup will optimize for the uses listed below.

What it's meant to do:
- Run 24/7 with very high reliability
- Handle multiple storage drives for dual-boot, potential NAS storage
- Transcribe signals from analog video to digital formats
- Be accessible from trusted devices in the local network

What it's not meant to do:
- Play games that require lots of computing power
- Mine cryptocurrencies


## the build

Building the pc in total took me about 2 hours for the physical setup and
testing, and another hour to get Linux set up as I wanted. At the time of
writing, I have used these components only for a short time, so I cannot give
a proper review. I plan on following up 6- 12 months from now with a review
based on what I've experienced.

### parts list

One of my unstated goals was to finish the build for under $500, and my parts
below at the time of writing cost in total about $450. You might be able to
find these cheaper depending on how prices change over time. The links below
are also not sponsored in any way, so please just use them as a reference.

**CPU**: [AMD Ryzen 3 2200G][ryzen3]

- includes onboard graphics
- cheap workhorse CPU
- if using an external PCI gpu, only uses PCI x8 mode even if your GPU supports
    x16. I've heard this is not a big deal, but just in case you care about
    maximizing your performance, I would do your research.

**Motherboard**: [MSI B450 Tomahawk ATX AM4][tomahawk]

- I sprung for the B450 over the B350 because of the support for more SATA III
    connections. Other than a few minor USB configuration differences, they are
    mostly the same. If you have a really old CPU, there might be some
    compatibility issues that are worth upgrading to the B450. At the time,
    there was a $10 difference, so I decided to upgrade.
- Includes a USB Type-C connector which was a non-negotiable for me.
- From an aesthetics perspective, the board looks really good and the color
    scheme fits in well with my case. It also has a few RGB LED headers you can
    use.

**Ram**: [Corsair 1x8gb DDR4 2400Mhz][corsair]

- I plan on adding another 1x8 GB stick in the future, but this suffices for
    now.
- Upon researching the different RAM speeds, it appears to make small
    performance improvements at 2800Mhz + but I opted to stay away for now.
- There are cheaper 1x8gb sticks out there from other brands, but I decided to
    go with Corsair's tried and tested model for my own sanity's sake and pay
    the extra $15.

**HDD**: [Samsung 860 Evo 250gb 2.5" SATA III][samsungssd]

- I wanted a smaller drive to run my Linux system, and for the NAS storage
    options I talked about in the future, I plan on getting WD 2TB red drives.
- This is the first SSD I've installed myself, and they are incredibly light,
    thin and cheap. SSD technology has come a long way since the relatively
    high prices 10 years ago.

**PSU**: [EVGA SuperNova G3 750W][psu]

- This is a fully modular power supply, if you care about cable management,
    it's worth the cost.
- EVGA has great customer service and a 10 year warranty, make sure to register
    your product.
- It includes an ECO mode that helps with quietting the fans and only running
    as necessary, but not a big selling point for me.

**Case**: [Cooler Master HAF XB EVO ATX Desktop][case]

- I didn't want a tower a build, but a more boxy build like the EVO.
- It is incredibly spacious, and makes it easy to route cables with zip tie
    loops throughout the case.
- Easy access to the motherboard makes it simple to service or modify if you
    keep it on your desk. The top and both side panels are removable to allow
    all encompassing access.

### order of operations

When looking up how to build your own pc, you'll find pretty similar high level
instructions for component order and what to do. There are always smaller
details like test booting and other miscellaneous items that seem to fall
through the cracks, so I thought I'd record what I did for next time. I am by
no means a build expert, so I defer to professional opinions if you find
conflicting information. This is simply a record of my particular build.

As most guides out there suggest, fully read through the list twice, before
removing a single item from packaging. If this is your first build, cross-check
it with other online resources if your parts are significantly different from mine.
Manuals are also your friend, I highly recommend reading each manual for your
motherboard, case, gpu and PSU with the priority being in that order. Every
build is different, and this is one case where it pays to read the manual
before starting to jam parts together.

One final note, I did not test-boot my motherboard while it was outside of the
case before the power and reset switches from the case were connected. I am not
experienced enough to understand how to manually power off the motherboard so
I opted not to do this as many experts recommend. My method is more
time-consuming if you misconfigured your motherboard and have to debug it once
it's in the case, but for me it was the safer option.

**WARNING** - *these steps do not include GPU installation, so please read your
manual if you are installing a GPU.*

1. Install CPU onto the motherboard. If this is your first time, please watch
   some Youtube videos for your specific processor installation to make sure
   you don't damage your CPU. The CPU is delicate, and there is room for error
   here if you aren't careful. If you are using the same CPU as I am,
   I recommend this particular [install video][ryzeninstall].

2. Mount CPU fan to the motherboard. My build uses the stock cooling fan for
   the Ryzen 3, and already includes thermal paste. I again recommend watching
   youtube videos for your specific cooler for mounting instructions and using
   thermal paste. Don't forget to attach the CPU fan power cable to the
   motherboard as specified in the manual.

3. Install RAM on the motherboard. Make sure you carefully read your
   motherboard manual to understand the mounting location. For example, I was
   only installing 1 stick of RAM, and its spot was in the 2nd from the left.
   Not the most intuitive, so always read the manual.

4. Install PSU to the case. At this point before the motherboard is installed,
   I recommend making sure that you attach all the power cables you need so
   that you don't have to dig under the motherboard later once it has already
   been mounted and there is limited space. In my case, I needed the MB cable,
   the CPU cable, one SATA power cable and one peripheral power cable for the
   front fans.

5. Install the standoffs to the motherboard mount. Mount the motherboard to the
   standoffs for a standard ATX motherboard. Refer to the case manual on
   specific instructions on how to do this. The [HAF XB EVO][case] has
   a removable mount that makes it easy to do this without having to fit your
   motherboard in the case yet.

6. Place the IO shield for your motherboard inside the case in the standard
   back slot. Make sure that it's oriented correctly before pressing it in.

7. Install the motherboard mount to the case, but only screw in a couple screws
   so that it's secure, but not too hard to remove later if necessary.

8. Read the motherboard and case manual to figure out how to attach the power
   and reset switches to the mother board. Optionally attach the Power and HDD
   LED's if you are confident.

9. Plug in the power cable, flip on the PSU switch and try turning it on. Your
   CPU fan should come on and some LEDs on the board will light up. The B450
   board I used includes some easy debug LEDs that can tell you if you are
   having CPU, RAM, VGA or boot issues. Once you see the BIOS come up, you made
   it!

10. If you successfully test boot, power off the system, turn off the PSU and
    fully unplug the PSU before starting to work on it again.

11. I mounted the SSD in the back HD mount of the case. The case I was using
    has 2 hot swappable drive mounts in the front, but I didn't want the
    primary boot drive to be easily removed. Carefully read your case manual
    about how to mount a 2.5" drive, usually there are adapters that make HD
    mountings compatible with both 2.5" and 3.5" drives.

12. Connect the SATA connectors to SATA1 on the motherboard, and connect the
    PSU SATA cable to your drive.

13. Connect the front USB 3 cables and audio cables to the motherboard. Again,
    this is always specific to each motherboard and case, so I highly recommend
    reading both manuals to ensure proper connections.

14. Connect any external fan power cables to your motherboard or PSU. Manuals
    come in handy as always!

At this point, your computer is all set for you to begin booting up your
particular OS boot drive if you have that ready. I recommend waiting to ziptie
and organize cables until the very und of the process, but that's up to you. If
you didn't fully mount the motherboard or PSU with all 4 screws, I highly
recommend you do that now.

### Linux Install


### Lessons Learned

As this was my first build in quite a while, I made some mistakes and learned
some things that I either forgot or hadn't experienced before.

- Don't forget to put your IO shield in early, I forgot to do this and had to
    move the motherboard late in the install after all the cables were plugged
    in.
- Connect all the PSU cables you need if you have a fully modular PSU. You can
    route them out of the side of the case temporarily to preserve space, but
    it's much easier to do it earlier than later once your motherboard is in.
- Have a USB keyboard and mouse available. I have been using Bluetooth
    keyboards for so long that I had to find an old one in storage.

[ryzeninstall]: https://www.youtube.com/watch?v=9VtH0EJRyAc
[ryzen3]: https://www.amazon.com/AMD-Ryzen-Processor-Radeon-Graphics/dp/B079D3DBNM/
[tomahawk]: https://www.amazon.com/MSI-Crossfire-Motherboard-B450-Tomahawk/dp/B07F7W5KJS/
[corsair]: https://www.amazon.com/gp/product/B01ARHBBPS/
[samsungssd]: https://www.amazon.com/Samsung-250GB-Internal-MZ-76E250B-AM/dp/B07864WMK8/
[psu]: https://www.amazon.com/EVGA-Supernova-Modular-Warranty-220-G3-0750-X1/dp/B005BE058W/
[case]: https://www.amazon.com/Cooler-Master-Computer-Radiator-RC-902XB-KKN2/dp/B00FFJ0H3Q/

