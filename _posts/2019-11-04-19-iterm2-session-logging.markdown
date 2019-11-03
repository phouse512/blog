---
layout: post
title: "Logging iTerm2 Activity"
date: 2019-11-04 12:00:00 -0600
categories: analytics linux
comments: true
---

I do most of my software development on OSX, and my terminal of choice is
[iTerm2][iterm]. iTerm2 is a full-featured terminal emulator built for Mac that
allows you to do some incredible customization. The recent release of 3.3 added
a new level of customization, a Python API with which you can customize almost
any aspect of your terminal. 

I have wanted to do keylogging / tracking on my terminal to get a better idea
of what aliases would be the most impactful, see patterns in my usage and so
on. Up until now, I haven't been able to find a useful open-source keylogger
for my environment. With the recent API release, iTerm2 has exposed all of its
internals, including the ability to hook into events on the terminal.

With the recent change, I decided to bite the bullet and build a small daemon
to begin capturing my usage of iTerm on my development machine.

## API Introduction

Before I get started, I highly recommend walking through the iTerm2
documentation and tutorials on getting started with the new API. [George
Nachman][george] and the rest of the iTerm team did a fantastic job documenting
and helping new users get their first script running. The examples listed are
also helpful, and in particular the [Alert on Long-Running Jobs][longjobscript]
script was helpful in demonstrating session monitoring capabilities.

I recommend downloading one, slightly modifying it and place it into your
iTerm2 directory to begin testing. Once you place scripts inside your
`~/Library/Application Support/iTerm2/Scripts` directory, you'll see iTerm load
it up in the Scripts menu option. Again, there is clear
[documentation][running] for this portion, so I'll point you there for
clear directions.

Finally, you can take advantage of the Scripts console to monitor currently
running scripts, see exception logging and more. You can easily start new
scripts, restart existing ones and manage what is going on behind the scenes.
See [Troubleshooting][troubleshoot] for more details.

## Logging Sessions

Compared to what you can do, my logging script is relatively simple. I had
a few goals:

- log sessions by name upon creation
- log commands by session
- log command exit status by session
- log command duration

My script uses `PromptMonitor` and `EachSessionOnceMonitor` to log sessions
opening up, and run a function that waits for any command input.

```python
async def main(connection):
    """
    This long running iTerm2 daemon logs commands, status's sessions, etc.
    :param connection: iTerm2 connection obj
    """
    app = await iterm2.async_get_app(connection)

    async def monitor(session_id):
        """
        Monitor a session for commands, log them out.
        :param session_id: str
        """
        session = app.get_session_by_id(session_id)
        logger.info("new session: %s", session_id)
        if not session:
            logger.warning("No session with id: %s", session_id)
            return

        modes = [
            iterm2.PromptMonitor.Mode.PROMPT,
            iterm2.PromptMonitor.Mode.COMMAND_START,
            iterm2.PromptMonitor.Mode.COMMAND_END,
        ]
        async with iterm2.PromptMonitor(connection, session_id, modes=modes) as mon:
            while True:
                # blocks until a status changes, new prompt, command starts, command finishes
                mode, info = await mon.async_get()
                if mode == iterm2.PromptMonitor.Mode.COMMAND_START:
                    logger.info("session-%s-command: %s", session_id, info)
                elif mode == iterm2.PromptMonitor.Mode.COMMAND_END:
                    logger.info("session-%s-status: %s", session_id, info)

    await iterm2.EachSessionOnceMonitor.async_foreach_session_create_task(app, monitor)
```

With `PrompMonitor`, you can listen to certain modes, so I connected to
commands start and ending, and logged those out along with the session id.
I use the standard python logging interface, and set up a rotating file handler
to turn over files once a day. If you'd like to see the full script, feel free
to check it out on [GitHub][scriptlink].

Running it 24/7 is as easy as putting it into the `Scripts/AutoLaunch`
directory and letting iTerm2 take care of the rest.

## Next Steps

I plan on running this logger on my machine for the next several months before
beginning to look at the data. Some potential questions I have, for fun and for
utility:

- what are the most common tools I use? which ones do I use for work? personal?
- which one of my current bash aliases are the most used? (or save the most
    keystrokes?) what are some commands that would benefit from being aliased?
- what commands keep me waiting the longest? If I find myself waiting hours
    a month for test suites to finish, maybe I should make it easy to run
    smaller sets.
- what series of commands should I combine into a single tool or uitility?

There are some transient errors around sessions closing or being interrupted,
but so far it has not impeded my script's ability to log any commands but I'd
like to solve the root cause if possible.


[iterm]: https://iterm2.com/
[george]: https://twitter.com/gnachman
[longjobscript]: https://iterm2.com/python-api/examples/autoalert.html
[running]: https://iterm2.com/python-api/tutorial/running.html
[troubleshoot]: https://iterm2.com/python-api/tutorial/troubleshooting.html
[scriptlink]: https://github.com/phouse512/piper_compute/blob/master/images/scripts/iterm2_logger.py
