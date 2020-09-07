---
layout: post
title: "Configuring the Raspberry Pi Zero W"
date: 2020-07-07 12:00:00 -0600
categories: devops pi
comments: true
---

I recently was working on getting the Raspberry Pi Zero W set up, a tiny
computer with a Wi-Fi chipset built-in. I run these headless, so I need to
manually configure these to be available via SSH right out of the box. This
will be a short overview of what I did, as it took way too long and I plan on
setting up many of these over the coming years.

### setup

#### flashing Raspbian lite

The first step is to download the Raspbian OS Lite image from the [Raspbian
website][raspbian]. Unzip that and keep the `.img` file accessible. You can use
`dd` or a tool like [Balena Etcher][balena] for OSX systems to flash the image
to your formatted SD card.


#### boot up the pi

Boot up the Pi using the PWR micro USB port, and give it a few minutes to
initialize for the first time.

#### configuring the OS

After the pi boots up, power it off and stick the SD card into your computer
once more. Once the SD card is mounted, we'll make a few modifications to add
WiFi credentials and enable SSH access.

In my [circlefiles][circlefiles] repository, I have a python script that uses the
python [invoke][invoke] library to make it easy to run tasks against your
machine.

```
# run rasp pi zero setup to configure Wi-Fi and enable ssh
$ inv rasp-pi-zero-setup
```

Once those steps are complete, the SD card can be ejected and added back to the
Pi. The Pi Zero is now ready to boot and should be able to connect to your Wi-Fi
without issue. Give it a few minutes to fully boot up, and then you can find
the IP on your router device list and connect.

```
# default user is pi and password is raspberry
$ ssh pi@<fake_ip>
```

#### looking ahead

These are some simple instructions that outline configuring a Pi Zero with
little to no extras added. I plan on adding Ansible playbooks to setup docker
and various other utilities sometime in the near future.

[invoke]: http://www.pyinvoke.org/
[circlefiles]: https://github.com/phouse512/circlefiles 
[balena]: https://www.balena.io/etcher/
[raspbian]: https://www.raspberrypi.org/downloads/raspberry-pi-os/

