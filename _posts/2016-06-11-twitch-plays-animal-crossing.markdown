---
layout: post
title: "Twitch Plays Animal Crossing: a postmortem"
date: 2016-06-11 18:23:29 -0600
categories: twitch crowdsourcing python emulators
comments: false
---

If you haven't heard of [Twitch Plays Pokemon][tpp], you should check out that
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
flow and spit out a token for me to use. The second one isn't hard either, but
if it slips past you when reading the documentation, you'll have some
potentially very tricky bugs once your code runs for a little while.

Once those individual pieces were figured out, I had to somehow glue them
together. I wanted the system to be able to handle a large load of chat
messages without affecting the rate at which the controller moved, meaning
I wanted the controller to move only once every given interval. I also wanted to be
able to plug in another data source instead of a Twitch chat (for example..
Twitter maybe?) so I tried to write the code to be as de-coupled as possible.
Because of this, I took advantage of the `Process` class from the
`multiprocessing` library, built into Python. At a high level, there was
a `TwitchStream` class that extended `Process` to run in a separate process
from the main controller. This class handled all incoming messages, processed
them accordingly and then put them on the `MessageProcessor`s message
buffer, a FIFO queue with a max size. As messages come in from the
`TwitchStream` in real-time, they get put on this queue, where every
third of a second a message will get pulled off and sent to the controller. If
more messages come in than the size of the FIFO queue allows, old messages will
get tossed, and the controller will choose the oldest message in that queue.
The reason for one more layer of separation here is to allow for future
selection strategies, such as the average of all commands in the last .4s, etc.
I wanted the controller to have as little knowledge at all of how messages were
converted to controls so that in the future the `MessageProcessor` can be
modified without affecting the actual controller code. You can take a look at
the below diagram for some more details:

![arena-diagram](https://raw.githubusercontent.com/phouse512/arena/master/scoreboard/final_gc_arena.png)

Doing it live!
==============

Once the basic structure was working, I decided to start streaming as soon as
I could to see what I would learn from trying it out. When I first started
streaming to Twitch, the only thing showing was the GameCube screen, other than
the chat, there wasn't much context for what was going on. After letting it go
for a few hours, the majority of people came, tried a few inputs, and then
left. There were others that were more dedicated and had specific goals, such
as getting the day to be halloween so that they could try to get Halloween
specials. Because the twitch chat isn't persistent, I decided to put some sort
of scoreboard so that passing visitors could see who was contributing, and that
they could see their inputs showing up when they typed text into the chat.

I built a small node app that runs alongside the controller code that would
listen on an endpoint to update a smiple UI that displayed top contributors,
latest inputs, etc. The controller would send requests every few seconds to
update the leaderboard so that it was pseudo-realtime. After redeploying this
and running it another weekend, you could see that the majority of people
contributed anywhere from 3- 30 commands total, but some would dedicate large
amounts of time, ranging from 100 to 300 inputs for the game. 

One of the biggest challenges I didn't anticipate was dealing with the 30s lag.
Like I mentioned above, Animal Crossing is a game that *mostly* doesn't require
real-time reactions - one of the biggest challenges was trying to talk to some
of the villagers that would literally run in circles around our character that
was always moving in the wrong direction because of the lag.

What's Next
===========

After spending a solid couple of weeks working on this, I'm going to shelve
some new changes for a little while once I get it running 100% of the time on
an Ubuntu box I'm currently setting up. Up til now, it's been running on
a beefy MacbookPro when I don't need it, but that's not a great long-term
solution. Since my programming solution requires a UNIX-based system, I don't
have the choice to do it on the Windows desktop I have at home without
dual-booting Ubuntu.

One of the other big fixes I want to add is stats persistence on startup and
shutdown. Right now if Dolphin crashes or something similar, I restart the
python application, it doesn't save state of the current users and history.
Unfortunately, this happens more than I would like right now, so I need to be
able to save to disk and reload on startup. I'm probably going to use some sort
of yaml solution since I've been on a yaml tear lately.

Next up is community-sourced goal-setting. For the random passerby in the chat,
they won't have any context about what is actually going on or what they should
try to push the character towards. I originally thought about just adding
a goal that I could update whenever I wanted in the node app, but I realized
that would get out of date really fast and wouldn't reflect the current state
of the game. Adding a custom command that would allow for users' to set this
could potentially turn out horribly but it could also be very useful, so it'll
be the next little experiment I try.

If you've made it this far, thanks for reading! Building this was a lot of fun
and I learned a lot from much of the poor multi-threaded application code
I wrote, but it was great practice. If you're interested in reading some of the
code I wrote for this, you can check it out on github [here][arena]. If you
want to see the actual stream, it's hosted on twitch of course, and it's found
[here][wisotv]. If you have any comments, ideas, or suggestions, feel free to
open an issue on Github or email me!

[twitch-chat-oauth]: http://www.twitchapps.com/tmi/
[spxtr]: https://github.com/spxtr
[arena]: https://github.com/phouse512/arena
[wisotv]: https://www.twitch.tv/wisotv
[gc-controller-pipes]: https://github.com/dolphin-emu/dolphin/pull/3170
[dolphin]: https://dolphin-emu.org/
[tpp]: https://en.wikipedia.org/wiki/Twitch_Plays_Pok%C3%A9mon
