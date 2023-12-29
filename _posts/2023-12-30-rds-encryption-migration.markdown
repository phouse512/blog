---
layout: post
title: "Encrypting Existing RDS Instances"
date: 2023-12-30 12:00:00 -0600
categories: dbadmin aws postgres
comments: true
---

It's been a while since I last wrote, and life has gotten a bit busier since
I last posted. My family welcomed a baby girl into the world, and we have
since found out we have another on the way. There have certainly been things
worth writing about, but none stood out so much as this topic.

Our company recently had to modify all of our RDS instances to be
encrypted-at-rest for compliance reasons. While this is now the default in
AWS, at the time when we started building our infrastructure (late 2017),
this was not the case. Moving our large production instance with
minimal-downtime was not as simple as we might have hoped, and required
experimentation and cobbling together various sources of information and
tooling.

The AWS documentation has a [dedicated article][aws] for this topic, which
does a great job of giving a high-level overview of what needs to be done.
Unfortunately, there are some critical details in my opinion that are missing.
I'd like to share our experience of what gaps we had to fill to get
everything to work smoothly. I recommend doing this migration on a
less-critical database to get some confidence and real-time experience
before doing it in production. To give you some sense of time,
the total migration time was about 5 hours, and application downtime lasted
15 minutes.

If you are a db admin, you will find this elementary. This is
written for those of us that are used to RDS magic, but find ourselves having to
make a more manual operational change than we're used to.


1. [Migration Overview](#migration-overview) 
2. [Detailed Walkthrough](#detailed-walkthrough)
3. [Gotchas](#gotchas)

### Migration Overview
As I mentioned, I do highly recommend reading through the AWS tutorial above
as it does give a good lay of the land. Just to briefly recap, here are the
big items that need to happen:

1. Create a new snapshot of the source database. Copy the snapshot, and
    encrypt it.
2. Start a new target database with the encrypted snapshot.
3. Disable foreign keys and triggers on target database.
4. Setup a DMS replication task that replicates source -> target, continuously.
5. Once DMS task is caught up, shut off writes to the source database.
6. Re-enable foreign keys, triggers and sequences on target database.
7. Switch over DNS entry to new target database, resume as normal.

If you are not already familiar with DMS (AWS's Database Migration Service),
you'll need to setup a replication instance ahead of time. You also need to
make sure there are replication endpoints for both the source and target
databases. I recommend testing the source endpoint before you start just to
get it out of the way.

I'm also assuming you are using CNAME dns records in your application settings
instead of the RDS endpoint directly. If you are not doing this, go ahead and
set that up first, as it will allow you to reduce downtime and make it easy to
cutover when the time comes.

### Detailed Walkthrough

Some of these steps are straightforward, but some of them have a ton of
configuration or confusing options to sort through. I'll try and walk through
each of them that we had to consider ourselves.

1. Copying a snapshot and encrypting it is basic. The only thing to think about
here is whether you want to use the default RDS KMS key for encryption, or a
customer or self-managed one. The encryption checkbox is all the way at the
bottom of the page.

2. Creating a new target database is straightforward as well, you just need to
make sure you copy over *all* the settings over from the existing database.
Make sure you use the same engine settings, network settings, master password
(or IAM auth), parameter group and option group. Double-check this, failing to
match this can cause time-consuming issues further in the process.

Once this is done, make sure to create a DMS endpoint for the target database,
and test the connection. This database won't populate in the DMS dropdown until
it is fully deployed and available.

3. In order for the DMS replication task to work, foreign keys and triggers on
the target database need to be disabled. Even on a small database, doing this
manually is almost impossible to do reliably. We created a script that
generates SQL statements for dropping the foreign keys, and used the following
SQL query to generate all foreign keys to drop.

```
-- list all foreign keys on a table in the public schema
SELECT conrelid::regclass AS table_name, 
       conname AS foreign_key
FROM   pg_constraint 
WHERE  contype = 'f' 
AND    connamespace = 'public'::regnamespace   
ORDER  BY conrelid::regclass::text, contype DESC;
```

We then templated in the `table_name` and `foreign_key` columns from above into
the following template in a custom Python script. Please note this is
potentially dangerous with unsanitized input and should only be done from known
input that you verify yourself. Our script is basic and not ready for
open-source, so you can template it however you'd like. I do recommend
scripting this so that you can generate this on-demand for different
databases. You can also just template out the statements directly in your SQL
query if you prefer as well.

```
ALTER TABLE {table} DROP CONSTRAINT {fk};\n
```

Disabling triggers is not so bad, as you can disable triggers without
completely deleting them. If you have more than a few triggers, I recommend
having this ready to go ahead of time. The less you have to generate on the fly
during the migration, the better - prework as much as you can.

```
-- select all triggers
SELECT event_object_table AS tab_name ,trigger_name
 FROM information_schema.triggers
 GROUP BY tab_name,   trigger_name
 ORDER BY tab_name,trigger_name ;

-- update trigger manually
ALTER TABLE <table_name> DISABLE TRIGGER <trigger_name>;
ALTER TABLE <table_name> ENABLE TRIGGER <trigger_name>;
```

4. Once the target database is ready, it's time to start replication using DMS.
There are a lot of levers in the AWS console here, and it's important to get
them right. 

- **Migration type**: Migrate existing data and replicate ongoing changes.
- **Task Settings** -> *Target table preparation mode*: Truncate
- **Task Settings**: Enable validation
- Check `Turn on Cloudwatch logs`.
- Check box at bottom, to keep task from starting upon setup.

For some reason, the AWS migration guide specifies using the `Truncate` mode,
which clears all row data, and migrates fresh. Because of this, we cannot use
`set_replication_role` in `replica` mode (see gotcha below).

We enabled validation also according to the AWS documentation. This extends the
actual migration task process by quite some time, but it does give peace of
mind. I recommend turning on the logs in Cloudwatch as this gives you
good visibility into what is breaking and why. If you forget to remove a
foreign key, for example, the logs will show why certain tables are not able to
be replicated properly.

Lastly, configuring the task but *not* starting it allows for one more chance
to review things and make sure things are all set before you go. If you have
already removed foreign keys and triggers, you can also just go for it.


#### Step 5: Running the DMS Task
Once the target database is ready and you've configured the DMS task, you are
to start the task. Depending on your database size, this could take anywhere
from 1-3 hours. In our case, the replication took 30 minutes but the validation
took almost 1 hour after the replication was finished. The AWS console gives a
good overview of what tables are in progress, and don't forget to scroll all
the way to the right to see the full table metrics.

### Gotchas
- not copying target db settings
- starting dms task on creation
- not providing enough time for dms task
- why not session_replication?

[aws]: https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/encrypt-an-existing-amazon-rds-for-postgresql-db-instance.html

