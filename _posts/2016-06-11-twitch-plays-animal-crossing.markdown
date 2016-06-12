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


High Level Points To discuss:
 - where the idea came from
 - how I went about getting the dolphin piping to work
    - include references in docs to dolphin prs
 - basic overview of architecture
    - pretty much a design doc
 - first run review
 - final takeaways
 - possible other solutions


[github-get-commits-for-repo]: https://developer.github.com/v3/repos/commits/#list-commits-on-a-repository
[github-get-commits-from-sha]: https://developer.github.com/v3/repos/commits/#get-a-single-commit
[set-cron-job]: https://www.setcronjob.com/
[piper]: https://github.com/phouse512/piper
