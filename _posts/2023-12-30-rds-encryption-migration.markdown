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
    1. [Step 1: Encrypting the Source Snapshot](#step-1-encrypting-the-source-snapshot)
    2. [Step 2: Creating the Encrypted Target Instance](#step-2-creating-the-encrypted-target-instance)
    3. [Step 3: Preparing Target Instance for Replication](#step-3-preparing-target-instance-for-replication)
    4. [Step 4: Configuring and Running the DMS Task](#step-4-configuring-and-running-the-dms-task)
    5. [Step 5: Stopping Writes on the Source Instance](#step-5-stopping-writes-on-the-source-instance)
    6. [Step 6: Restoring Foreign Keys, Triggers and Sequences](#step-6-restoring-foreign-keys-triggers-and-sequences)
    7. [Step 7: Ending Downtime, Cleaning Up](#step-7-ending-downtime-cleaning-up)
3. [Random Notes](#random-notes)

&nbsp;
&nbsp;

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

&nbsp;
&nbsp;

### Detailed Walkthrough

Some of these steps are straightforward, but some of them have a ton of
configuration or confusing options to sort through. I'll try and walk through
each of them that we had to consider ourselves.

&nbsp;

#### Step 1: Encrypting the Source Snapshot

Copying a snapshot and encrypting it is basic. The only thing to think about
here is whether you want to use the default RDS KMS key for encryption, or a
customer or self-managed one. The encryption checkbox is all the way at the
bottom of the page.

&nbsp;
&nbsp;

#### Step 2: Creating the Encrypted Target Instance

Creating a new target database is straightforward as well, you just need to
make sure you copy over *all* the settings over from the existing database.
Make sure you use the same engine settings, network settings, master password
(or IAM auth), parameter group and option group. Double-check this, failing to
match this can cause time-consuming issues further in the process.

Once this is done, make sure to create a DMS endpoint for the target database,
and test the connection. This database won't populate in the DMS dropdown until
it is fully deployed and available.

&nbsp;
&nbsp;

#### Step 3: Preparing Target Instance for Replication

In order for the DMS replication task to work, foreign keys and triggers on
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

&nbsp;
&nbsp;

#### Step 4: Configuring and Running the DMS Task

Once the target database is ready, it's time to start replication using DMS.
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

Configuring the task but *not* starting it allows for one more chance
to review things and make sure things are all set before you go. If you have
already removed foreign keys and triggers, you can also just go for it.

Once the target database is ready and you've configured the DMS task, you are
ready to start the task. Depending on your database size, this could take anywhere
from 1-3 hours. In our case, the replication took 30 minutes but the validation
took almost 1 hour after the replication was finished. The AWS console gives a
good overview of what tables are in progress, and don't forget to scroll all
the way to the right to see the full table metrics.

&nbsp;
&nbsp;

#### Step 5: Stopping Writes on the Source Instance

Once the DMS task is at 100% and validation is complete, you are now ready to
begin the cutting over process, and start downtime. Before we can switch over
to using the target database, we need to stop any new writes to the source
database, so that nothing gets lost. You can handle this whatever way works
for your architecture. If there is a straightforward monolith, you can just
stop those instances. In our case, it was much easier to just add a restrictive
security group that only allowed access from my machine. You still need access
to the source database, so make sure you have a way to connect, however that
is.

In addition to stopping application access, you can also stop the DMS
replication task at this time. It will take a minute or two, but you should see
connection activity and CPU activity drop significantly on the source.

&nbsp;
&nbsp;

#### Step 6: Restoring Foreign Keys, Triggers and Sequences

This step is the most complex, and time critical as you are on the clock with
application downtime at this point. I **really recommend going through this step
against a test database at least once** before you take down your production
environment.

When searching for details about this process, I came across
[this project][project] by [Sin-Woo Bang][sinwoo]. He built some tooling for
automating the cleanup tasks to get your target database ready for the
switchover. It's pretty well-documented and I recommend using it to restore
your foreign keys and sequences. An aside here, it does attempt to restore
indexes as well as foreign key constraints, but those error out quietly as they
already exist. He saved us a bunch of work, and helped answer some questions we
had about the process as well. Thanks Sin-Woo!

Once you have restored your sequences and foreign keys, you can turn the
triggers back on, using the SQL from Step 3. At this point, planned downtime
can come to an end. I hope you can understand why running through this step
in practice is important, the faster you do this, the quicker your users are
back online.

&nbsp;
&nbsp;

#### Step 7: Ending Downtime, Cleaning Up

At this point, you can point your CNAME dns record at the new target database,
and restart your services if necessary. Traffic should pick up on the new
encrypted database as normal, and you should be all set. Once things are
stable, you can go back and start cleaning up the mess left in your wake. A
couple things to remember:

1. Take a final snapshot of the source database, and shut it down, once you
feel confident that the target database has taken over without issue.

2. Cleanup the DMS task, and replication instance once it is no longer needed.

3. Create any read-replicas as necessary for the new target database.

Other than that, you are done! Let me if you have any questions or experience
doing the same - I'm sure there are some other notes and tips I could add here.


&nbsp;
&nbsp;
&nbsp;

### Random Notes

&nbsp;

#### Why not use `session_replication_role` to disable foreign keys?

When doing the preparation, I came across [several][soreplication]
[resources][repsourcetwo] that mentioned you could set the replication
role to `replica` for the DMS migration, without requiring disabling
foreign keys and triggers. I tried this route, but unfortunately found that
this wouldn't work when using the `TRUNCATE` option in DMS, as mentioned in
the [DMS documentation here][dmsnosession]. I believe you could use DMS to
replicate without using `TRUNCATE`, but given I am not an expert, I opted to
follow the process laid out specifically for the encryption migration. I would
love to hear how to make it work using this, as it is much simpler.

```sql
-- prepare for migration
SET session_replication_role = 'replica';

-- post migration re-enablement
SET session_replication_role = 'origin';
```

See note about `session_replication_role` being incompatible with `TRUNCATE`
operations, when foreign key constraints exist.
> PostgreSQL has a failsafe mechanism to prevent a table from being truncated, even when
                session_replication_role is set. You can use this as an alternative to
            disabling triggers, to help the full load run to completion. To do this, set the target
            table preparation mode to DO_NOTHING. Otherwise, DROP and TRUNCATE
            operations fail when there are foreign key constraints.

&nbsp;
&nbsp;

#### How do I migrate my source database replicas?

The simplest thing to do is leave your source replicas untouched, and setup
the new target database with replicas once the target is generally available.
In most scenarios, I imagine you can allow applications to use the original
read replica, as data will be slightly stale but available until the switch.
If that kind of lag is unnacceptable, you will have to either settle for more
downtime on services relying on the replica, or point those services at the
target database temporarily, until the replicas have time to get up and running
from the new target database.


[aws]: https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/encrypt-an-existing-amazon-rds-for-postgresql-db-instance.html
[project]: https://github.com/sinwoobang/dms-psql-post-data
[sinwoo]: https://sinwoobang.notion.site/sinwoobang/Sin-Woo-Bang-796475b665ec48c39d721a9343f3dabf
[soreplication]: https://stackoverflow.com/questions/38112379/disable-postgresql-foreign-key-checks-for-migrations/49584660#49584660
[repsourcetwo]: https://www.pythian.com/blog/migrate-postgres-database-from-ec2-instance-to-rds-using-aws-dms-data-migration-services
[dmsnosession]: https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Target.PostgreSQL.html
