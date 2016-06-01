---
layout: post
title: "Using Github for Personal Trends"
date: 2016-05-25 8:30:53 -0600
categories: infrastructure piper github
comments: false
---

Like many developers out there, I'm a pretty avid user of Github, and I use it for all of my private and public writing and programming. Until recently, I had been thinking about moving my repos into a self-hosted service such as [gitlab][gitlab], but when Github began offering [unlimited repos][unlimited-repos], I decided to stick around for a little longer. With that being said, there is a tremendous amount of personal metadata for any heavy user of Github, especially when used for both work and play. Knowing the frequency, time, and even contents of your commits over time would allow for some interesting analysis and learning, as well as a good historical record of your programming timeline. Operations like this aren't cheap, and I didn't want to depend on live-querying Github to get all commit data whenever I wanted to run scripts, so I decided to build a small mirror of a user's git metadata that could be updated with a daily cronjob. I currently have a small api that I use for various reoccuring jobs that this scraping task will fit well into.

Planning for this, there were a few important pieces of data that I wanted to
store for later querying: 1) additions/deletions for commits, 2) file
extensions for commits, as well as 3) time of day for the commit. The Github
API was not the most straight forward in terms of getting fully-populated
commit objects, but I finally figured it out after a lot of manual curling and
tests. The basic approach I took is listed below, but keep in mind that
as of writing this post, this is v3 of the github api and I doubt that every change is backwards-compatible.

1. Grab every git repository for a given user, using [this endpoint][github-get-repos]. One important thing here that I had to mess around with here was which repos would actually get returned from this call. Depending on your github usage/flow, you'll have to tweak the `visibility`, `affiliation`, and `type` parameters to get exactly what you want.

2. For each of the repositories, my aggregator then [grabs all of the recent commits][github-get-commits-for-repo] made by the auth'd user for that repo. Once again, some configuring of the `sha` and `since` params will get you what you want, namely which branches you want to track, and how far back you want to go back. The shas returned by Github here are what you'll need for the following query to get the actual commit.

3. Now with this list of shas, this [final endpoint][github-commits-from-sha]
   will return a fully populated commit that has full addition/deletion counts,
   as well as additions/deletions for each file in the commit.

Since piper is a django app, I decided to add an additional endpoint to handle
the daily save job, instead of a random script. Because I wanted an easy way to
see the curl response and I didn't want to have to ssh into any of my boxes to
do it, I went with [SetCronJob][set-cron-job]. I currently have the job setup
to run everyday at midnight, so by the following morning I should have
everything I need to build notifications and some sort of interface. 

For a while I've had a cheap Android tablet sitting on my desk collecting dust,
and I've toyed with the idea of putting it on my wall to display relevant
metrics, such as these. In the future, I want to build some more advanced trend-detection and smart grouping, but for now a simple endpoint that 'tails' the latest commit activity will be enough to get started with.

If you're curious about what the code looks like, you can take a look at the
[piper repo][piper], hosted on Github. I'm slowly adding unit tests to the
scraping code as to help make it less brittle, so take it with a grain of salt.
If you have ideas for how to deal with branches, organizations, and other git
metrics worth checking, create an issue or send an email!




[unlimited-repos]: https://github.com/blog/2164-introducing-unlimited-private-repositories
[gitlab]: https://about.gitlab.com/
[github-get-repos]: https://developer.github.com/v3/repos/#list-your-repositories
[github-get-commits-for-repo]: https://developer.github.com/v3/repos/commits/#list-commits-on-a-repository
[github-get-commits-from-sha]: https://developer.github.com/v3/repos/commits/#get-a-single-commit
[set-cron-job]: https://www.setcronjob.com/
[piper]: https://github.com/phouse512/piper
