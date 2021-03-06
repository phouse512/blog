---
layout: post
title: "Hosting and Deploying Node Services"
date: 2017-02-13 16:20:00 -0600
categories: node
comments: true
---

Ever since Node came into the world about 7+ years ago, an increasing number
of web applications are hosted and run in some capacity with it. There are
dozens of tutorials and examples to help you get an [express][express] server
running on your local machine. Other frameworks like [meteor][meteor] can also
get real-time server-client interactions right out of the box.

Today we're going to look at getting these Node web applications up and running
on a remote Ubuntu server. We'll set up your server to run your webapp, make
sure that your application stays up and running, and make it really easy to
deploy new changes.


### Server Setup

First, it's important to make sure that your server is ready to host your
application and present it to the world. Throughout this post, I will be
assuming you are running an Ubuntu 14.04 server. While most of these commands
should be transferrable for other systems, they may not and you might have to
make some simple modifications.

One of the key aspects to standardizing your Node environment is to use a tool
called [nvm][nvm]. nvm allows for users to easily manage Node versions and
switch between them. Using nvm allows you to explicitly choose what version of
Node you want to run. You don't have to worry about `PATH` issues or wonder if
your `.bashrc` or `.bash_profile` scripts ran correctly.

The following steps are taken from nvm's documentation, so if something doesn't
work, refer to the docs for help. Let's start by installing it to your machine:

```
$ curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
```

Run `source ~/.bashrc` to make sure that nvm is added to your path, and then
run `command -v nvm` to ensure that it was installed correctly. If it was, it
will output `nvm` to your terminal.

Now you can install whatever version you'd like, and switch between them
seamlessly. For example, to see what versions of Node you currently have, you
can use `nvm list`. If you want to install version 4.7 for example, you can run
`nvm install 4.7`, and then set it as the current version by running `nvm use
4.7`. If you check the Node version by running `which node`, you can see the
full path, managed by nvm.

```
$ nvm list  # lists all of the node environments installed
$ nvm install 4.7  # installs node v4.7 on your machine
$ nvm use 4.7  # sets v4.7 as the current node path
$ which node  # show path managed by nvm
```

We'll also want to install [nginx][nginx] if you don't have it already. It's
pretty simple, you can do this with the following two commands:

```
$ sudo apt-get update
$ sudo apt-get install nginx
```

With both of those tools set up, we have everything we need to get our web
applications up and running. Next, let's look at getting your server to run!


### Running your Web Application

There are 2 important aspects to hosting a web application. 1) We need
to make sure that the Node server is running 24/7, and 2) the outside world
needs to be able to access your server running on the machine.

#### Using Forever to Run Your Server

We'll use a tool called [forever][forever] to run your Node app. To install it,
you simply need to run the following command:

```
$ npm install forever -g
```

The above command uses npm to install forever globally on your server, which
adds it to your path. As a note, you will most likely need to run this with
sudo privileges to install it correctly.

Before starting the server, first make sure that nvm is set to the correct
version of Node, by using the `nvm use <version>` command we talked about
earlier. Navigate to your project directory, and then run `npm install` to make
sure that all of your dependencies are ready to go.

To start the server using forever, run the following command from inside your
project directory:

```
$ forever start <your app/index.js filename>
```

That will spit out a few lines about the server starting up, and it will look
something like this:

![forever output]({{ site.url }}/assets/forever_output.png)

Now your server will be running forever, or until it hits an exception that it
cannot recover from. You can use forever to run multiple Node applications at
once - to see what's currently running, use `forever list`. Forever comes with
intuitive arguments like `stop` and `restart` which perform as expected.

To see the output logs of your Node application, forever also creates a custom
location by default. When you ran `forever list`, you see that there is
a column titled logfile which displays the path to the logfile. You can also
customize this by using some of the forever command flags. This post isn't
about foreverjs, so I'll leave the rest up to you and the
[documentation][forever].

#### Making Your Server Visible

Now your server is running locally on whatever port you setup, but it isn't
accessible on the default port 80 used for web requests. What we'll do is use
nginx to route incoming requests on port 80 to your Node app.

This post will also not go into some of the intricacies of running and using
nginx, but we'll go through a basic configuration. We'll also assume that you
are working with a vanilla nginx configuration - if not, I assume you have
enough working knowledge to modify these steps accordingly.

First, let's create a new file that will hold your nginx config:

```
$ vim /etc/nginx/sites-available/node_app
```

Inside that file, we want to put the following contents, slightly modified for
your port number.

```
server {
    listen 80;

    location / {
        proxy_pass http://localhost:<your_port_#>/;
    }
}
```

The above configuration is pretty self-explanatory. First, it tells nginx to
listen for incoming http requests on port 80. It then takes all of those
requests and forwards them to your Node application running on your specified
port number.

Next, we have to actually add this configuration to nginx - and we do that by
creating a [symlink][symlink] in another directory to this config file we just
created. To do that, run the following command:

```
$ sudo ln -s /etc/nginx/sites-available/node_app /etc/nginx/sites-enabled/node_app
```

As you can see, the first argument is the path of the file we want to create
a link to, and the second argument is the path of the new symlink we are
creating. To modify nginx configs, all you need to do is add new configuration
files in the `sites-enabled` directory for it to pick them up. Symlinks just
make it easy to swap them out without actually deleting files.

The final step is to make sure that nginx picks up the new configuration. We
can do that by running this:

```
$ sudo service nginx reload
```

If all goes well, this should give you an `[OK]` message, and nginx has the
correct config! If your Node application is running, you should be able to
access it on the internet now, by going to `http://your.IP.address/`. If you
want the request to work from a custom domain name you have, there will be
a little bit more work reserved for another time.

Your application is now up and running, and you should be able to make changes,
restart your Node server using forever, and see them live on the internet!


[express]: http://expressjs.com/
[nvm]: https://github.com/creationix/nvm
[nginx]: https://www.nginx.com/resources/wiki/
[forever]: https://github.com/foreverjs/forever 
[symlink]: https://en.wikipedia.org/wiki/Symbolic_link#POSIX_and_Unix-like_operating_systems
[meteor]: https://www.meteor.com/
