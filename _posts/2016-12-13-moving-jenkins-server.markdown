---
layout: post
title: "Moving an Existing Jenkins Installation"
date: 2016-12-14 12:34:00 -0600
categories: jenkins cloud migration
comments: true
---

I recently was reviewing some monthly expenses and noticed that my Digital
Ocean monthly bill was higher than I once thought. After digging around,
I realized there was an extra 1gb droplet that wasn't doing much anymore.

The only service it was running was my small Jenkins server that I use for some
continuous integration and testing. I decided to switch it over to another
smaller server I have that wasn't being completely utilized. Migrating a single
node Jenkins server wasn't as straightforward as I thought it might be, so
here's a little overview of the process I went through to switch it.

### Overview

Before we get started, check out this Stack Overflow [question][jenkins-so]
that gives high level steps to migration. It gave me a good foundation to get
started, but there were many small things to fix along the way that I'll write
about.

Here are the major components to migrating:
- on your new server, install jenkins. I am running Ubuntu, so I followed this
  [article][jenkins-install].
- on both servers, stop jenkins by running `sudo service jenkins stop` (again,
  I am running Ubuntu 14.04). Your mileage may vary depending on your system.
- next, you'll need to zip up your `JENKINS_HOME` directory before sending it
  to your new server. For my installation, the default was in
  `/var/lib/jenkins`. I used `tar -zcvf jenkins-backup.tar.gz
  /var/lib/jenkins/*`.
- you can now use [scp][scp] to send the entire tar package to your new server.
  If you don't have SSH credentials set up, check out this [blog
  post][own_ssh].
- unzip the file into your new `JENKINS_HOME` using `tar xvzf <tar_name>`.
- now you are ready to restart Jenkins! Run `sudo service jenkins start` to get
  jenkins running again with your new configuration.


### Pitfalls

Along the way, I ran into many speedbumps as there always are. Some took more
time than others, so here's a short list of potential issues to watch out for:

#### SSH Credentials

For whatever reason, Jenkins ssh credential files were not copied (although the
references were still in my Jenkins config). I simply ran `ssh-keygen` to
generate a new pair of SSH credentials, and added the new public key to the
remote location.

Some of my Jenkins jobs were configured to SSH into remote servers and run some
commands. Turns out that some of those remote hosts were now under a different
user on the same machine as the Jenkins process. While at first I fiddled
around with using `rsync` and `cp` locally, soon I realized it wasn't worth the
hassle of dealing with user and group permissions. 

If you find yourself in the boat, you can SSH into a different account on
localhost for a password-less login. Here's an example:

``` 
rsync -a . phil@localhost:/home/user/my_custom_path/ 
```

#### Memory Issues

Jenkins is a Java service, and it will eat memory every meal of the week if 
you let it. After I copied over my Jenkins configuration and updated my old
jobs, it was time to start Jenkins on the new server. While I restarted,
I tailed the logs, and everything looked fine but the processes would randomly
crash and Jenkins would die.

After watching [htop][htop] for a couople more starts/deaths, I realized it was
because Jenkins was quickly consuming memory. Because it was OOM'ing, it was getting
killed before it could log anything to the Jenkins log files. I [ack'd][ack] my
`/var/log/kern.log` file to find it, and here it showed up:

```
Dec  7 09:24:48 piper kernel: [35657191.139947] Out of memory: Kill process
2691 (java) score 350 or sacrifice child
Dec  7 09:24:48 piper kernel: [35657191.140076] Killed process 2691 (java)
total-vm:2143088kB, anon-rss:175172kB, file-rss:0kB
Dec  7 09:30:53 piper kernel: [35657556.376662] java invoked oom-killer:
gfp_mask=0x201da, order=0, oom_score_adj=0
Dec  7 09:30:53 piper kernel: [35657556.376677] java cpuset=/ mems_allowed=0
Dec  7 09:30:53 piper kernel: [35657556.376690] CPU: 0 PID: 3365 Comm: java Not
tainted 3.13.0-57-generic #95-Ubuntu
```

While Jenkins configurations can become massive and require lots of resources,
mine certainly doesn't, so I went ahead and set some worker and memory limits
on my configuration.

In `/etc/default/jenkins`, I modified the following line from:

`JAVA_ARGS="-Djava.awt.headless=true"` 

to this:

`JAVA_ARGS="-Djava.awt.headless=true -Xmx256m"`

By setting that above, you limit the maximum size of the memory allocation
pool. As a heads up, `Xmx` is not the total size of the memory used by your
JVM, it is the memory size of the heap.

Next, I modified `/var/lib/jenkins/config.xml` and changed the `numExecutors`
xml tag from 2 to 1. While this limits my Jenkins configuration to process one
queued job at once, it's ok as I don't have any running concurrently. This
might be overkill for you, especially if you are on a server with more than 1gb
of RAM.

Finally, I also added some swap for heavy loads, using one of Digital Ocean's
fantastic [tutorials][swap_tut].

#### Updating Documentation/webhooks

The final and most obvious heads-up is to make sure that all of your services,
processes and workflows that depend on Jenkins switch to the new server
location. Don't forget your GitHub hooks, integrated tests, and anything else
that depends on Jenkins. 

This shouldn't be too hard if you centralize all of your documentation :)


[jenkins-so]: http://stackoverflow.com/questions/8724939/how-to-move-jenkins-from-one-pc-to-another
[htop]: https://hisham.hm/htop/
[ack]: http://beyondgrep.com/
[swap_tut]: https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-ubuntu-14-04
[own_ssh]: http://www.phizzle.space/linux/cloud/ssh/security/github/2016/10/30/configuring-ssh-keys-linux.html
[scp]: http://www.hypexr.org/linux_scp_help.php
[jenkins-install]: https://wiki.jenkins-ci.org/display/JENKINS/Installing+Jenkins+on+Ubuntu

