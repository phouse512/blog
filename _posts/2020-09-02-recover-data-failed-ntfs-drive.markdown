---
layout: post
title: "Recovering Data from a Failed NTFS Drive"
date: 2020-09-03 12:00:00 -0600
categories: linux ubuntu data
comments: true
---

A family member recently came to me with a portable hard drive that was no longer
readable onto a Windows OS. After confirming I was seeing the same issue on my
own Windows PC, I went down the rabbit hole of attempting to recover as much
data as possible from the failed drive. I documented the path I took below, as
well as some notes if you ever find yourself in the same position.

### cloning the damaged drive

If you have a drive that can't be read anymore, chances are that only a portion
of it is dead, and many (if not most) sectors might still be readable. The more
time passes between initial failure and imaging the drive, the higher the
chance the drive might continue to fail as it powers on/off.

[GNU ddrescue][ddrescue] is a great recovery tool that copies from a block
device to another. I won't go into details about the documentation, since you
can read that yourself, but it does its job very well. Below are some important
notes about how to install and use it.

Be sure to install it by using `sudo apt-get install gddrescue`, `ddrescue` is
an older, incomplete script.

ddrescue requires that the input file be visible when you run `sudo lsblk`, so
if the device doesn't even register there, unfortunately this won't help you.

You will need an output disk that can contain the entire failed disk, not just
the amount you used, so if you have a 1TB hard drive you are attempting to
recover, I recommend using at least a 2TB hard drive to store the output.
ddrescue copies block for block, and doesn't know anything about the contents.

ddrescue can be run with a mapfile that can allow the process to be picked up
at any time, so you can take a break or shutdown your computer if desired. I've
read that some people don't run it too long in one session to prevent the
damaged disk from getting too hot, but that seems anecdotal.

The actual command I ended up running was `sudo ddrescue -r
2 /dev/damaged_drive /media/large_backup_drive/image
/media/large_backup_drive/logfile`.

The final output file is called `image` and the mapfile is called `logfile` on
the `large_backup_drive` in the above example. It also will attempt to retry
bad sectors two additional times.

Lastly, be aware that this is a very time consuming process, especially when
you start retrying sectors. For my 1 TB hard drive, in total ddrescue ran for
over 70 hours to fully process and retry the failed sectors.

### fixing the drive structure

Once you have imaged the drive, you can attempt some of the various tools to
fix the structure of your NTFS partition, like `fsck`. Some people have had
success with other tools as well, but none of these worked for me. It's worth
a shot, and here is a link to a discussion about some of the options you have.

[SuperUser - Fix corrupt NTFS partition without Windows][fix]

### recovering data



[ddrescue]: https://www.gnu.org/software/ddrescue/ddrescue.html 
[fix]: https://askubuntu.com/questions/47700/fix-corrupt-ntfs-partition-without-windows

