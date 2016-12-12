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

<for all below points, should be few sentences per..>

Here are the major components to migrating:
- on your new server, install jenkins (show command here)
- on both servers, stop jenkins by doing (show command)
- archive /var/lib/jenkins using tar
- scp the tar file to the new server
- unzip the directory on the new server, and move it into /var/lib/jenkins
- launch new jenkins


### Pitfalls

Along the way, I ran into many speedbumps, here they are:


#### SSH Credentials

for whatever reason, Jenkins ssh credentials (id_rsa) were not copied (although the
references were in jenkins config). I had to manually get the old key for this
jenkins user. 

Also, some of my jenkins jobs now needed to SSH into the local machine as
a different user. how did I set that up


#### Memory Issues

Jenkins is a Java service, likes to eat memory for breakfast. New server was
smaller, and immediately my Jenkins processes would get killed for putting the
machine OOM.

It took me a little while to debug, but once I did I was able to set strict
memory limits on Jenkins. <how I did it>

I also added swap using some of Digital Ocean's fantastic tutorials <links>

#### Updating Documentation/webhooks 

<self explanatory>



[jenkins-so]: http://stackoverflow.com/questions/8724939/how-to-move-jenkins-from-one-pc-to-another
