---
layout: post
title: "Version Control with Flyway"
date: 2017-12-06 12:00:00 -0600
categories: db postgres flyway
comments: true
---

It's been a while since my last post with the main reason being that things
have gotten really busy at [amper][amper]. In the past couple months, we've hired
another software engineer and a data scientist. As you can imagine, moving from
engineers working solo to teams requires more processes and tools to help
maintain order and keep people from stepping on toes.

From the beginning, we've used things like continuous integration,
unit-tests and version control for our code. Something that we've put off is
applying similar principles to our database. We use a Postgres RDS instance
hosted by AWS, and connect many of our services to it. When we've needed to
make changes, it was a matter of jumping on the instance and manually writing
SQL for table/index modifications. This has been fine with only two people on
the team, but as we grow, this doesn't scale anymore.

Growing our team is the main reason why we've started version controlling our
database, but it's not the only one. When I got started with this concept,
I found Jeff Atwood's [blog post][db-control] on version controlling the
database to be very helpful. There are other resources as well that give some
solid reasons for moving in that direction, and I won't rehash them here.

We ended up going with [flyway][flyway], a Java-based tool that helps with this
process. It is built on using simple SQL scripts that are numbered and get
applied sequentially to bring database schemas up-to-date. The documentation
was decent at explaining the core functionality and usage of the tool, but
I found resources for using flyway in a production environment to be lacking.
The rest of this blog post will be about how amper uses flyway and integrates
it into our workflows. I don't claim that our usage is the standard, but it has
been useful in getting ourselves up and running!

### flyway in practice

One of the first confusing things that tripped us up was figuring out how to
structure our repository. When you download flyway for the first time, it comes
with many directories: some for config files, jars, sql and more. This is what
the structure of our repository looks like:

```
.circleci/  # holds our circleci build configurations
  config.yml
conf/  # holds all of our configuration files for database locations
  factory_dev.conf
  factory_prod.conf
  factory_test_ci.conf
  flyway.conf
seed/  # for storing timestamped dump data when developing
  11_30_17_dump.sql
sql/  # where our sql migrations get stored
  V001__sample_sql.sql
  V002__another_sample.sql
  V003__more_sql.sql
users/  # sql that holds the user accounts
  admin.sql
.gitignore
README.md
initialize.sh  # used to set up the db locally
install_flyway.sh  # used to download, unzip and setup flyway
run_ci.sh  # used by circleci to run sql against test db
seed.sh  # adds the seed data to the local dev db
```

I'll briefly go over each section and detail the most important bits. The first
important directory is `conf/`. Inside that directory, you'll find multiple
configuration files that specify different database logins depending on their
name. For example, here is what my `factory_dev.conf` file looks like:

```
flyway.url=jdbc:postgresql://localhost:5432/dev_db
flyway.user=postgres
flyway.locations=filesystem:sql
```

These configuration files are pretty simple, and if you want to read more about
configuration files, you can find documentation [here][config-doc].

[flyway]: https://flywaydb.org/
[db-control]: https://blog.codinghorror.com/get-your-database-under-version-control/
[amper]: https://www.amper.xyz/
[config-doc]: https://flywaydb.org/documentation/commandline/ 
