---
layout: post
title: "Modernizing Your Media Archives"
date: 2016-09-12 18:32:00 -0600
categories: cloud s3 media storage
comments: false
---

When I was in middle-school, I received a [MiniDV][minidv] camcorder. I used it
for a few years to record a lot of fun memories, but as HD cameras/phones
became able to record directly to hard drives, my video camera became obsolete.
It sat on on one of my shelves for many years until my parents recently moved
and I was forced to clean up my old stuff. I decided to digitize all the tapes
I had before either a. the magnetic tapes' reached their [physical
lifetimes][life] or b. there are no more mediums with which I can watch DV tapes. 

The camcorder has a built-in 4-pin Firewire port, and I've used that in the
past to digitize some video, so I looked for a Mac that I could connect it to.
None of the variations of modern Mac laoptops have any Firewire ports, but
luckily a friend had an earlier MacbookPro with a 9-pin Firewire port. iMovie
made it easy to transfer, and now all of my videos are backed up in the cloud
for the long-term! 

I would recommend to any of you in the same boat as I was to look into modernizing your
media collection. While in the past 20 years, formats for media
storage have changed drastically (think of floppies, cassettes, CDs, etc.),
with the prevalance and cost-efficiency of cloud storage, I think it's a safe
bet to transfer your media now. In the next 5-10 years, it will only get harder
to access and view any old media formats you might have as specialized media
readers and adapters get harder to find.

By using a specialized cloud storage company, you put the burden on them to
manage rotating hard-drives, hardware failure, [data rot][data], etc. You 
only have to worry about having an Internet connection and computer the next 
time you'd like to break out that hilarious video at your next family reunion.

Also, if you're squeamish about the idea of letting a cloud storage provider
handle your files because you're afraid they might get lost, read [this][quora] Quora
post about a discussion of the reliability of [Amazon's S3][s3] storage. The
odds you're facing there are on orders of magnitude smaller than the risk you
have keeping a shoebox of old cassette tapes in your basement.

For those of you worried about the security and privacy of your data when it's
stored in the cloud..well.. you're [not wrong][lavabit]. Even if your data is
encrypted, cloud companies may potentially be forced to give over those
encryption keys to the government if they so demand. To counter that, I'm
currently working on a cloud-storage portal that leaves the encryption keys in
your hands only. If that sounds interesting, let me know!

[minidv]: https://en.wikipedia.org/wiki/DV#Magnetic_tape
[life]: https://www.clir.org/pubs/reports/pub54/4life_expectancy.html
[data]: https://en.wikipedia.org/wiki/Data_degradation
[quora]: https://www.quora.com/Has-anyone-actually-ever-lost-data-using-Amazon-S3-reduced-redundancy-option
[lavabit]: https://en.wikipedia.org/wiki/Lavabit#Connection_to_Edward_Snowden
[s3]: https://aws.amazon.com/s3/
