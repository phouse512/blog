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
the structure of our repository looks like. I'll briefly go over what each
section is responsible for below.

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

#### configuration files

The first important directory is `conf/`. Inside that directory, you'll find
multiple configuration files that specify different database logins
depending on their name. For example, here is what my
`factory_dev.conf` file looks like:

```
flyway.url=jdbc:postgresql://localhost:5432/dev_db
flyway.user=postgres
flyway.locations=filesystem:sql
```

These configuration files are pretty simple, and if you want to read more about
configuration files, you can find documentation [here][config-doc]. We use
a separate configuration file for each development environment in order to make
it clear when we are running migrations.

#### sql migrations

The next important directory is `sql/` - this directory is more
self-explanatory. It holds the numbered sql files that flyway uses to migrate
your database. The flyway documentation is pretty clear about how this works,
so I'll leave that to you to figure out.

#### user Configuration

Inside `users/` we store sql scripts that hold the configuration for consistent
users for ourselves and our services. I create new credentials for each
service, along with fine-grained permissions based on what each service needs. 

```
/* user accounts */
CREATE USER admin_user WITH PASSWORD 'fake_pass';
CREATE USER user1 WITH PASSWORD 'fake_pass';
CREATE USER service1 WITH PASSWORD 'fake_pass';

/* give all priv's to admin_user */
GRANT ALL PRIVILEGES ON DATABASE "test_db" to admin_user;

/* give read-only privileges to user1 */
GRANT SELECT ON ALL TABLES IN SCHEMA test_schema TO user1;
ALTER DEFAULT PRIVILEGES IN SCHEMA test_schema GRANT SELECT ON TABLES TO user1;

/* give read/write privileges to service1 */
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA test_schema TO service1;
ALTER DEFAULT PRIVILEGES IN SCHEMA test_schema GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO service1;
```

We keep this outside our SQL migrations to allow for us to maintain consistent
permissions across all of our servers. The credentials generated here are what
the configuration files use to connect/run migrations, so it's a bit of
a chicken-and-egg problem. The `initialize.sh` script in the root of our
directory automatically runs these permissions commands to save some time and
`psql` syntax lookups. This is definitely one of the more experimental
aspects of our flyway usage, so we'll see how this evolves over time.

#### scripting

The rest of the contents in this directory are helper scripts that make common
actions a little bit easier. `initalize.sh` is used to ease getting a local
database up and running locally. `seed.sh` makes it easy to load in seed data
from the `seeds/` directory. We also include a script that our continous
integration tools use to automatically validate new migrations.

### practical workflows

With the repository structure set up, let's go over how we actually use flyway.
I'll go over two basic workflows, 1) initializing a local development database
and 2) making changes to the production database schema.

#### local setup

When a new developer joins the team, or we're setting up a new development
machine, we follow this workflow. It's not completely automated, but the most
critical parts have been to help reduce human error.

1. Set up a local instance of Postgres, this can be done with Docker, brew or
   any other packages.
2. Manually create a database with the name that your dev configuration uses.
3. Run the `initialize.sh` script which takes care of user and schema
   initialization.
4. Migrate the clean database to the current production schema with `flyway
   migrate`.
5. Optional: Add some seed data to the database by running the script
   `seed.sh`.

As you can see, it's pretty simple, and it handles most of the complicated
aspects for you. Once you have a database installed and running, our process
takes care of almost all of it for you! We also use a similar flow when we want
to blow our local DB and bring it back up to latest, especially after lots of
testing.

#### making changes

The next most common workflow is actually making changes to the database. These
steps assume that you already have the latest production schema running in your
local database.

1. Checkout a new branch in the database repo.
2. Using `psql` or your favorite DB admin tool, modify the database to fit your
   requirements. Be sure to keep track of exactly what you did if you spent
   a bunch of time experimenting.
3. Place all of your new changes in a sql file, and be sure to name it
   following the flyway convention. By default, it requires numerically-ordered
   files that look like this: `V001__some_change.sql`. Add a new file and
   increment the lateset version so that flyway can pick it up.
4. Open a pull-request, and let the CI server pick up your changes and ensure
   that your sql runs without error.
5. Merge the pull-request, and then run `flyway migrate` against your
   production database.

This flow is also pretty simple, it makes it very clear for everyone to review
what exactly you're doing to the database. And while we don't have complex
migration validation with our CI (it uses an empty DB), we can at least
validate that it is valid sql on an outside machine. Next, I'll share a little
bit more about how we've set up our testing flow.

### continuous testing


### looking forward

- improve setup process
- automate seed data
- add better CI testing with real data



#### production changes

[flyway]: https://flywaydb.org/
[db-control]: https://blog.codinghorror.com/get-your-database-under-version-control/
[amper]: https://www.amper.xyz/
[config-doc]: https://flywaydb.org/documentation/commandline/ 
