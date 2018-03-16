---
layout: post
title: "Migrating my blog to S3 and Cloudfront"
date: 2018-03-20 12:00:00 -0600
categories: s3 cloudfront blog
comments: true
---

When I first began this blog, I decided to host it on a small Digital Ocean
droplet. At the time, it made sense - I was learning about managing Ubuntu
servers, firewalls and dns routing. I've learned a bunch since then, and lately
my focus has centered around building reliable data systems. I haven't had time
to properly manage my blog hosting and maintain the toolchain around it.

It's built with Jekyll, and over time as I've switched computers, tried
installing new gems and more, my local Ruby installation is completely out of
sync. I was also previously using a Jenkins server for continuous integration
and deployment, but since then I've stopped it to reduce cost.

As a result, writing new posts has become a chore that requires me to wrestle
with Jekyll, test and then remember how to deploy manually. One of my 2018
goals is to simplify the projects that I work on and make sure that they are
easily maintainable moving forward. With that in mind, today I'll be walking
through the process of modernizing all of the operations around my blog.



# development and writing

My first goal was to make writing new posts and testing local with Jekyll as
easy as possible. The biggest issue is managing my local Ruby installation and
making sure it keeps building. To deal with this, I decided to use a Docker
image with Jekyll and ruby already installed.

Thankfully [envygeeks][envygeeks] maintains a popular [Docker
image][jekylldocker] that I was able to out of the box, without building my own
Dockerfile from scratch. From there, it was just a matter of modifying my
Makefile to run a simple bash script inside of the image.

```
# Makefile

development:
	docker run --rm -p 4000:4000 --volume="${PWD}:/srv/jekyll" \
        -it jekyll/jekyll ./scripts/development.sh

build:
	docker run --rm --volume="${PWD}:/srv/jekyll"  \
        -it jekyll/jekyll ./scripts/build.sh
```

There are just a few important things to note here about how I use docker to
build:

- I begin by connecting my current directory with `/srv/jekyll` in the
    container. The Dockerfile in the image uses the following line: `WORKDIR
    /srv/jekyll` so this is where our commands will get run from.
- I use `--rm` to delete the container after it shuts down, I don't need
    a bunch of old containers filling up my hard drive.
- port 4000 from the container is connected to 4000 on the host (my computer)
    so I can easily test `http://localhost:4000/` in the browser. 

The scripts used are even simpler, as shown below. Since jekyll is already
installed, these are just a simple wrapper around in-case I want to add more
tasks in the future. One last note, since the volumes are shared between my
current dir and the container, `jekyll serve` detects changes as I write and
immediately regenerates so I can proof-read and test quickly.

```
# scripts/development.sh

#!/usr/bin/env bash
jekyll build
jekyll serve


# scripts/deploy.sh

#!/usr/bin/env bash
jekyll build
```

# continuous integration and deployment

The next step was to setup [Travis-CI][travis]


# serverless hosting with s3 and cloudfront


# future ideas

- integrate a spell-check into the toolchain
- parse and perform simple map-reduce stats on cloudfront logs

[travis]: https://travis-ci.org
[jekylldocker]: https://github.com/envygeeks/jekyll-docker/
[envygeeks]: https://github.com/envygeeks/
