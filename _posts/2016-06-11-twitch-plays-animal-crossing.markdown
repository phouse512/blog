---
layout: post
title: "Twitch Plays Animal Crossing: a postmortem"
date: 2016-06-11 18:23:29 -0600
categories: twitch crowdsourcing python emulators
comments: false
---

If you haven't heard of {Twitch Plays Pokemon][tpp], you should check out that
Wikipedia article to get some bacgkround so that when I reference Twitch Plays
Pokemon (TPP), it makes sense. Recently I began to wonder about the possibility
of experimenting with another system I grew up with, the Gamecube. The GC
controller is way more complex than a Gameboy's inputs so the choice of games
was definitely limited (nothing like Smash or Monkeyball - anything that
requires real-time). I decided upon using Animal Crossing, a single-player RPG
that doesn't require a lot of real-time reactions, which is perfect for the
~30s Twitch lag. I had to figure out how to build a system that converts
a chat conversation into Gamecube controller inputs, and this blog will be
a bit a dive into the software that makes it work.

Emulation and Controls
======================

The first trick was to figure out how to programmatically control a Gamecube
from my computer. After a little research, it appeared that the [Dolphin
emulator][dolphin] is one of the more popular and still active emulators for
Wii and Gamecube games, so I decided to go with that one. To simulate
controller inputs, I first began to look into python libraries for keypresses
on OSX, but unfortunately all I found was some meagerly maintained solutions or
direct actionscript call examples and I wasn't too keen on going down that
route. After a little more searching, I found [this pull request][gc-controller-pipes],
evidence that one of the Dolphin devs put in the ability to input controls via
named pipes on unix systems. With that, I realized this idea was possible and
I began building out some test code that interfaced my python program with
Dolphin emulator - there was some tricky configuration with the Dolphin
controller settings, but thankfully [spxtr][spxtr] documented it pretty well.

Next up was wrangling the Twitch chat and piping that into a separate thread.
Twitch allows for us to connect using IRC, and while there are more complicated
python libs for IRC support, I decided to go with the simple solution, the
stdlib's socket interface. There were only a couple gotchas here, one being
that Twitch IRC now requires an oauth token and that every ~5 minutes or so,
Twitch sends out a `PING` message that you need to respond to with a `PONG` so
that it keeps the connection open. For the first one, I just ended up using
a third party [oauth token generator][twitch-chat-oauth] that handled the oauth
flow and spit out a token for me to use.


High Level Points To discuss:
 - where the idea came from
 - how I went about getting the dolphin piping to work
    - include references in docs to dolphin prs
 - basic overview of architecture
    - pretty much a design doc
 - first run review
 - final takeaways
 - possible other solutions

[twitch-chat-oauth]: http://www.twitchapps.com/tmi/
[spxtr]: https://github.com/spxtr
[github-get-commits-for-repo]: https://developer.github.com/v3/repos/commits/#list-commits-on-a-repository
[github-get-commits-from-sha]: https://developer.github.com/v3/repos/commits/#get-a-single-commit
[set-cron-job]: https://www.setcronjob.com/
[piper]: https://github.com/phouse512/piper
