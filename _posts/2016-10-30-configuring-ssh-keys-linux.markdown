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

As you can also tell from the above, your personal SSH key-pair can be used to
access multiple servers. As long as you put your public key in the
`authorized_keys` file of the user you want to connect as, you won't have any
more configuration work. We'll see what this looks like as we step through the
setup process.


#### Creating your SSH keys

The responsbility of creating an SSH key pair falls to the remote user, the
client. These next set of instructions will pertain only to this process, and
all should be run on your local machine. There is a utility called `ssh-keygen`
that should already be installed. Run it like this:

```
ssh-keygen
```

You'll be given a prompt that looks like the following:

```
Generating public/private rsa key pair.
Enter file in which to save the key (/home/username/.ssh/id_rsa):
```

This prompt asks you where you would like to have your key pair stored, and
this default location is usually just fine. SSH configuration info is by
default stored in the `~/.ssh` directory. Unless you changed the name of the
key, the the private key will be named `id_rsa` and its public key
`id_rsa.pub`. If you decide to change this, you will have some extra
configuration work to get your SSH client to find the keys.

As a note, if you already have a private/public key pair in your `~/.ssh`
directory, it will ask you if you want to overwrite the old one. Do _not_ do
this unless you are ok with nullifying your existing SSH access to servers.

```
Created directory '/home/username/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again: 
```

The next prompt will ask you for a passphrase for your key pair. This is
optional, but it is *highly* recommended. Using a passphrase for SSH does not
detract from the security benefit SSH gives. A passphrase is used only
_locally_ to decrypt the the key to be used in the process described above. The
passphrase or the private key are _never_ passed across the network, as what
happens when using password authentication with SSH.

At this point, you are done! You should have an `id_rsa` and `id_rsa.pub` file
that can now be used to connect to servers.


[concrete details about ssh key setup]


[github key setup]
[whyssh]: http://security.stackexchange.com/questions/3887/is-using-a-public-key-for-logging-in-to-ssh-any-better-than-saving-a-password
[do]: https://digitalocean.com
