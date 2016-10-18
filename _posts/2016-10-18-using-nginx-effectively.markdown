---
layout: post
title: "Practical Nginx"
date: 2016-10-18 05:53:00 -0600
categories: linux nginx cloud
comments: false
---

## Outline of Nginx
For those of you who've never heard of Nginx, it is a free, open-source,
high-performance HTTP server and reverse proxy (taken from the [Nginx
docs][docs]). While Nginx advertises itself as a high-performance,
production-grade application (which it [is][perf]), it is also incredibly
useful as a reverse-proxy. I'll share about how I configure Nginx to route
requests amongst mhy various projects.

If you've never heard of a [reverse proxy][proxy] before, let me give a brief
introduction. Let's say you are hosting a website on a small AWS instance you
have spun up. You get a decent amount of traffic, and you don't want people
using your website to be able to find out the actual IP address of your server,
since you use it for testing or other purposes. A reverse proxy can stand in
the public gateway of the internet and forward requests to your web server so
that the outside world can't find out the server that is actually responsible
for the requests. I've included a diagram below so you can get a better idea of
what I'm talking about:

[image yeahhhh]

Reverse proxies have many usages and advantages, but I use Nginx mostly for
it's ability to distribute incoming requests to several different servers.
I have around 4 or 5 projects at any given time hosted on the internet, but
I don't need a dedicated EC2 instance for each of those - in fact, they could
all run fine off of one box. The problem is, all of these projects are unique-
among them static websites, node servers, Django api's, and more. Not only
that, but I also have different domain names and required paths for each of
them. I'll go through some of the different use cases and share some of the
Nginx configs that have been helpful for me in quickly getting my projects on
the web. As a note, all of the below configurations are examples of a single
Nginx instance on the same server as all of my web applications.

Django Configurations
=====================

For those of you using Django, Nginx makes it easy to get your server pointed
at a Django instance configured to run on localhost.


```
server {
    listen 80;
    server_name <domain_name>;

    location /static/ {
        root /home/user/path/to/django_repo;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/user/path/to/django_repo/file.sock;
    }
}
```

In Nginx, this config is called a server block, and is a complete configuration 
that Nginx can use to distribute incoming requests. You can have many or just
one, depending on what you are working on.

Let's step through this and take a look at what is going on here. The first
directive: `listen 80;` is pretty clear, it is telling nginx to listen on port
80 for this particular kind of request. The next line is crucial
- `server_name` is used to tell Nginx with which server block to forward an
incoming request to. In your case, depending on what domain name you have for
your Django server, you can configure this as necessary. I might have a line
like `server_name api.phizzle.space;` or something similar.

The next three lines beginning with `location /static/ { ...` are used to help
incoming requests trying to find the static resources you've configured in your
Django application. Depending on how you configured Django and your static
assets, this might change. This little block grabs all incoming requests with
`/static/` in the url path and forwards them to the static resources in your
Django application as necessary.

The next location block `location / { ...` catches all the rest of the incoming
requests. It preserves the url path, and passes the request to the local unix
socket of your Django application. It preserves the parameters and sends the
HTTP packet as-is to the locally running Django server. The socket path here is
also different for each user, and it again depends on how you've configured
your Django application.


[proxy]: https://en.wikipedia.org/wiki/Reverse_proxy

#### Nginx example for django

#### Nginx example for node

#### Nginx example for static

#### Nginx multi server blocks 
