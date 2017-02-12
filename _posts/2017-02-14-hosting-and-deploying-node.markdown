---
layout: post
title: "Hosting and Deploying Node Services"
date: 2017-02-07 16:20:00 -0600
categories: node
comments: true
---

Ever since node came into the world about 7+ years ago, an increasing number
of web applications are hosted and run in some capacity with node. There are
dozens of tutorials and examples to help you get an [express][express] server
running on your local machine. If you want to use webpack to bundle your
[es6][es6] code, it's equally as easy to find example configuration files to
get up and running.

Today we're going to look at getting these node web applications up and running
on a remote Ubuntu server. We'll look at setting up your server to run your
service, making sure your application stays up and running, and making it
really easy to deploy new changes.


### Server Setup

First, it's important to make sure that your server is ready to host your
application and present it to the world. Throughout this post, I will be
assuming you are running an Ubuntu 14.04 server. While most of these commands
should be transferrable, they may not and you might have to make some simple
modifications.

One of the key aspects to standardizing your node environment is to use a tool
called [nvm][nvm]. nvm allows for users to easily manage node versions and
switch between them. Using nvm allows you to explicitly choose what version of
node you want to run. You don't have to worry about PATH issues or wondering if
your bashrc or bash_profile ran correctly.

The following steps are taken from nvm's documentation, so if something doesn't
work, refer to the docs for help. Let's start by installing it to your machine:

`curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh
| bash`

Run `source ~/.bashrc` to make sure that nvm is added to your path, and then
run `command -v nvm` to ensure that it was installed correctly. If it was, it
will output `nvm` to your terminal.

Now you can install whatever version you'd like, and switch between them
seamlessly. For example, to see what versions of node you currently have, you
can use `nvm list`. If you want to install version 4.7 for example, you can run
`nvm install 4.7`, and then set it as the current version by running `nvm use
4.7`. If you check the node version by running `which node`, you can see the
full path, managed by nvm.

We'll also want to install [nginx][nginx] if you don't have it already. It's
pretty simple, you can do this with the following two commands:

```
sudo apt-get update
sudo apt-get install nginx
```

With both of those tools set up, we have everything we need to get our web
applications up and running. Next, let's look at getting your server to run and
served to the internet!


### Running your Web Application


install forever

start the server

simple nginx configuration

### deploying node

talk about why you want to rsync your build, and not run webpack up there

for small projects, doing this from local is fine, for bigger projects, use
jenkins or a deploy server to help standardize your testing process

go into using `rsync` to deploy and send code

[express]: http://expressjs.com/
[nvm]: https://github.com/creationix/nvm
