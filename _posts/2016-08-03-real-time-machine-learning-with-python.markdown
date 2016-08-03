---
layout: post
title: "Building a real-time prediction algorithm with Python 3"
date: 2016-08-03 18:05:13 -0600
categories: python real-time machine-learning 
comments: false
---

This past month, I recently quit my job to begin working full-time on
a hardware IoT product. As one of the lead developers on the project

<some information about the problem here> <include graph>

the sky-high view
=================

Before I delve into the inner-workings of how the service works, I figure it'll
make more sense to highlight the overall goals and moving pieces of the
project. The goal of the entire system is to take in a large number of
separate, streaming inputs and classify them individually into the appropriate
category. Every given second, these inputs have more than 5 unique features
that can be used to help classify what kind of signal it is. The inputs are
streaming, so there is no clear start or end state, things happen in real-time,
and our system needs to be able to handle that accordingly. Ideally, this
computation will be performed as quickly as possible so that the user can get
near real-time feedback on what is happening.

The more we thought about the problem, the more we realized that there are two
distinct challenges here that can be de-coupled and tacked on their own:

1. event-detection: before we can even classify a signal, we need an actual
   signal to classify. Because every second we are gaining 10s of new
   datapoints, the process has to be able to decide when 'events' start and
   end.

2. event-classification: once we have an event, then we can run that event
   through the appropriate trained models to get a prediction of what that
   signal represents.

As you can tell, once we break this apart, it becomes slightly less
intimidating, we can focus on solving these individually and putting the parts
back together. Also, the challenges have different requirements that we were
able to take advantage of when designing our system, namely the fact that
event-classification is not really a streaming/real-time challenge. Because we
can assume that events will be detected in the first part of our system, this
portion takes in a single event and does its best to classify it. It doesn't
have to maintain state that needs to be updated with incoming streams (models
do need to be trained, but that doesn't constantly need updating) so it is
almost as simple as a function call.


event detection
===============

Based on the graphs above, 


is v2.0 actually better?
========================

What's Next
===========

[tpp]: https://en.wikipedia.org/wiki/Twitch_Plays_Pok%C3%A9mon
