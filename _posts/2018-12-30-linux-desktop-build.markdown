---
layout: post
title: "Building a Desktop Linux PC from Scratch"
date: 2018-12-30 12:00:00 -0600
categories: linux diy build
comments: true
---

# building a desktop Linux PC

For the past 7 years, I've almost exclusively lived off 3 different laptops
that I've owned. Between the three of them, I've used one Windows 7 machine,
and two OSX laptops. The OSX laptops have been the most reliable and common
ones that I've used for development the past 5 years. The Windows laptop died
a few years into usage and I haven't touched it since. In the meantime, I've
wanted to work on getting a home network setup with NAS and various other
utilities. To set all that up, a Linux home base seemed to be a prerequisite 

1. [goals](#1)
2. [the build](#2)
3. [stability and burn-in](#3)
4. [configuration management](#4)
5. [backup and storage](#5)

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
