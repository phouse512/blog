---
layout: post
title: "Migrating Hosting to S3 and Cloudfront"
date: 2018-03-20 12:00:00 -0600
categories: s3 cloudfront blog
comments: true
---

When I began this blog, I decided to host it on a small Digital Ocean
droplet. At the time, it made sense - I was learning about managing Ubuntu
servers, firewalls and dns routing. I've learned a bunch since then, and lately
my focus has centered around building reliable data systems. I haven't had time
to properly manage my blog hosting and maintain the toolchain around it.

It's built with Jekyll, and over time as I've switched computers, tried
installing new gems and more, my local Ruby installation is completely out of
sync. I was also previously using a Jenkins server for continuous integration
and deployment, but since then I've stopped it to cut costs.

As a result, writing new posts has become a chore that requires me to wrestle
with Jekyll, test and then remember how to deploy manually. One of my 2018
goals is to simplify the projects that I work on and make sure that they are
easily maintainable moving forward. With that in mind, today I'll be walking
through the process of modernizing all the operations around my blog.


# development and writing

My first goal was to make writing new posts and testing local with Jekyll as
easy as possible. In the past, It was hard to manage my local
Ruby installation and keep everything up-to-date. To deal with this, I
decided to use a Docker image with Jekyll and ruby already installed.

Thankfully [envygeeks][envygeeks] maintains a popular [Docker
image][jekylldocker] that I was able to out of the box, without building my
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


# scripts/build.sh

#!/usr/bin/env bash
jekyll build
```


# serverless hosting with s3 and cloudfront

Next, I wanted to remove all operational overhead
of hosting my own static website. Amazon's S3 service is a perfect fit and
allows for static websites to be hosted without any personal maintenance.
On top of that, Cloudfront can be used to offer a CDN service in front of S3 to
improve latency. For many static sites, these tools are a great fit and allow
for you to pay only for what you use and nothing more.

Deploying on this setup is as simple as syncing jekyll's static output to your
S3 bucket. After that you only need to invalidate the Cloudfront cache in front
of your bucket to ensure that your changes propagate.


# continuous integration and deployment

The final step was to set up [Travis-CI][travis] to automate testing and
deployment. Travis-CI supports a new [jobs][travis-jobs] feature that allows
for serial job pipelines that are great for setting up build and deploy
pipelines. Here is the barebones configuration I use to only deploy on
merges to master.

```
# .travis.yml configuration
sudo: required
services:
  - docker

stages:
  - build
  - name: deploy
    if: branch = master

jobs:
  include:
    - stage: build
      script: make build
    - stage: deploy
      script: make deploy
```

Since I already have a Makefile setup for things like building and testing,
I added another `make deploy` command so that it's easy for me to deploy from
my machine and from a CI server. I just have to pass in my AWS creds to my
Docker image as environment variables and let it go.

```
deploy: build
	docker run --rm --volume="${PWD}:/build" -it \
	-e AWS_ACCESS_KEY_ID=<access_key> \
	-e AWS_SECRET_ACCESS_KEY=<secret_key> \
	-e AWS_DEFAULT_REGION=<region_name> \
	library/python:3.6 ./build/scripts/deploy.sh
```

My deploy script is very simple, it is based on a Python image, so Python and
pip are already installed. From there, installing `awscli` is a breeze, and we
only need to sync our local directory with S3 and invalidate the Cloudfront
cache.

```
#!/bin/bash
echo "Running deploy"

echo "Install aws-cli"
pip install awscli --upgrade --user

echo "Beginning deploy"
~/.local/bin/aws s3 sync ./build/_site s3://<bucket_name>
~/.local/bin/aws cloudfront create-invalidation --distribution-id <distribution_id> --paths /\*
```


# future ideas

These changes go a long way in helping me post often and without much effort,
but there are a few more nice-to-haves that I'll save for another weekend.

I would like to have a command-line spelling/grammar check built into my
testing workflows. The only way I do it now is to copy and paste each blog post
into an online editor once before posting.

Cloudfront logs all of its requests to file before compressing and storing them
in a S3 bucket. While I already use tools like Google Analytics and Gaug.es,
it would be great practice for my `sed`, `awk` and `grep` skills to build some
basic analyzing scripts for my Makefile.

[travis]: https://travis-ci.org
[travis-jobs]: https://docs.travis-ci.com/user/build-stages/#What-are-Build-Stages%3F
[jekylldocker]: https://github.com/envygeeks/jekyll-docker/
[envygeeks]: https://github.com/envygeeks/
