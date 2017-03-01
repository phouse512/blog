---
layout: post
title: "Avoiding Locks when using psycopg2"
date: 2017-02-13 16:20:00 -0600
categories: python postgres
comments: true
---

Recently I was using the [psycopg2][psycopg2] library in a periodic task that
I was using to alert myself when a website went down. There was a single
query that selected a few rows from a table and that's it. I'll show some code
that looks similar to what I was doing below.

Anyways, I realized that an extra column was necessary, but when I tried
running my `ALTER` query, it would hang indefinitely manually killing it. After
some searching around the Internet, I found the following query which
illuminated the unintentional lock on my table.

```
db=> select * from pg_locks where relation=(select oid from pg_class where
relname='<table_name>');
```

![postgres-output]({{ site.url }}/assets/psql.png)

When run against my Postgres instance, saw something like the following showed
up. While I'm not 100% sure about all the details here (`AccessShareLock`, for
example), it was enough to make me start looking into my code to see what was 
holding the table in contention.

The code that was accessing the query looked something along the lines of this:

```
def get_heartbeats():
    
    cursor.execute("SELECT name, last_received FROM heartbeater WHERE
                    active=true")

    hb_list = cursor.fetchall():

    for heartbeat in hb_list:
        # do some logic here
```

The function `get_heartbeats` was part of a [celery][celery] task that would
run every minute or so and supplied the DB connection and cursor. As you can
see, I never called `connection.commit()` after executing and fetching the data
from my query. Since this was a long running process, the session remained idle
and open, and ultimately locked the table from outside queries and manipulations.

Once I did some digging in the [psycopg2 documentation][psycopg2_docs], I found
that my usage was wrong. Quoted from the documentation below:

> By default even a simple SELECT will start a transaction: in
> long-running programs, if no further action is taken, the session will remain
> “idle in transaction”, an undesirable condition for several reasons (locks are
> held by the session, tables bloat...). For long lived scripts, either make sure
> to terminate a transaction as soon as possible or use an autocommit connection.

To remedy the mistake, I simply called `connection.commit()` at the end of each
function call. After redeploying, the long-term locks were removed and there
were no further issues. If you have any long-running processes making queries
with `psycopg2`, double-check to make sure that you are closing transactions
promptly either explicitly or by using the [autocommit][autocommit] property.

[psycopg2]: http://initd.org/psycopg
[psycopg2_docs]: http://initd.org/psycopg/docs/usage.html#transactions-control
[celery]: http://www.celeryproject.org/
[autocommit]: http://initd.org/psycopg/docs/connection.html#connection.autocommit 
