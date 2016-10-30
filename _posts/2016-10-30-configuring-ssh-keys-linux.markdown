---
layout: post
title: "Configuring SSH keys for Linux Servers and Github- 2016"
date: 2016-10-30 03:53:00 -0600
categories: linux cloud ssh security github
comments: true
---

Once you have a Linux server up, it's important to get your SSH key
authentication set-up. When you set up a server with [Digital Ocean][do], you
will use your root password to connect to the server your first few times, but
don't make a habit of it. I won't go into why public key pair authentication is
more secure here, but you can read a bit more in this helpful [stack
exchange][whyssh] conversation. Before we get started going into setting up
your SSH keys, let's look at how SSH key authentication works in the first
place.

A SSH key pair consists of two keys that are used to authenticate client
connections to remote SSH servers. A key pair consists of two parts, a public
key and a private key. The *public* key can be shared without worry about
security - it is public as its name implies. By themselves, these keys are
useless without their private counterparts. Public keys are used to encrypt
messages that only their respective private keys can decrypt, but are useless
for anything more.

On the other hand, *private* keys must be kept secure and secret. These keys
are kept by the client and are used to decrypt messages in the SSH key
handshake. If a hacker obtains your private key, the hacker will be able to
access any server with it's public key counterpart without any additional
security. Additionally, you should always encrypt your private key on your local machine with
a passphrase but more on that later.

Here is a diagram that illustrates the 



[diagram about ssh client and server]

[diagram between multiple users and multiple servers]


[concrete details about ssh key setup]


[github key setup]
[whyssh]: http://security.stackexchange.com/questions/3887/is-using-a-public-key-for-logging-in-to-ssh-any-better-than-saving-a-password
[do]: https://digitalocean.com
