---
layout: post
title:  "Understanding Django's prefetch_related"
date:   2016-03-08 18:50:35 -0600
categories: django orm
comments: true
---

If you're anything like me, using the Django ORM can be a tricky and confusing experience without much clue as to what's going on underneath the covers. This usually leads me to writing queries from scratch and dealing with error handling manually, but today I'll try to help you make sense of the `prefetch_related` method and how it can be used. I'm going to assume you have a working understanding of Django, so if some of the assumptions I make below don't make sense to you, make sure to check out the [basic Django tutorial][django-starting] first.

First, let's talk about what prefetch should, and shouldn't be used for. When building up your models using the ORM, it's inevitable that you will use foreign keys to reference other objects. In the case of one-to-one relationships, another Django method: `select_related` will be the most useful in saving the number of queries being made. I won't be going over that too much here, and if you'd like to learn more, you can read this [blog post][select-related-blog]. For one-to-many and many-to-many relationships, optimizing the django orm so that it's not making dozens of requests can be a little trickier, and this is where `prefetch_related` comes in handy. I'll walk through an example with and without using `prefetch_related`, so you'll be able to see exactly what's going on.

### Setup

We'll need a few models that represent a many-to-many relationship in real life, so I went ahead and set some up for us to use:

{% highlight python %}
class Message(models.Model):
    id = models.AutoField(primary_key=True)
    message = models.TextField()
    delivery = models.DateTimeField()
    labels = models.ManyToManyField(Label, through='MessageLabels')
{% endhighlight %}

{% highlight python %}
class Label(models.Model):
    id = models.AutoField(primary_key=True)
    text = models.TextField()
    type = models.IntegerField(default=0)
{% endhighlight %}

{% highlight python %}
class MessageLabels(models.Model):
    id = models.AutoField(primary_key=True)
    label = models.ForeignKey(Label)
    message = models.ForeignKey(Message)
{% endhighlight %}

As you can see here, we have messages that can be tagged by labels. Each message might have a different set of labels, and sometimes we will want to know the text of each label for a message. For example, we might be displaying a list of messages with their labels displayed inline on the screen, where we will want to know the type, and text of each label for each message.


##### Note:
> In this example, I am defining the 'middle' table that allows us to join many messages to many labels to be the `MessageLabels` class. Django can handle this for you when using the [ManyToManyField][many-to-many-doc] and *not* specifying the [through][django-through] attribute, as I did above.

Next, we need to populate our database with some test data. For now you can just assume I have the following loaded:

- 4 Labels
- 3 Messages - each with all 4 labels attached through the `MessageLabels` model

We want to list through all the messages and display the message, as well as the labels for each one. Below is a simple example of something we can test against, where the object `messages` is the return result of some queryset.
{% highlight python %}
def getMessagesDictionary(messages)
  message_dict = {}
  for message in messages:
    print message

    for label in message.labels.all():
	  print label.text
{% endhighlight %}


#### Naive Approach
Given this setup, we can test to see what will happen if we don't use the prefetch method.
To test the number of queries being made, we can import the `db` object from django and see the length of the queries list as shown:

{% highlight python %}
from django import db

messages = Message.objects.all()
getMessagesDictionary(messages)

print len(db.connection.queries)
> 4

print db.connection.queries[3]
> QUERY = u'SELECT "cool_messages_label"."id", "cool_messages_label"."text", "cool_messages_label"."type" 
FROM "cool_messages_label" INNER JOIN "cool_messages_messagelabels" 
ON ( "cool_messages_label"."id" = "cool_messages_messagelabels"."label_id" ) 
WHERE "cool_messages_messagelabels"."message_id" = %s' - PARAMS = (3,)

print db.connection.queries[2]
> QUERY = u'SELECT "cool_messages_label"."id", "cool_messages_label"."text", "cool_messages_label"."type" 
FROM "cool_messages_label" INNER JOIN "cool_messages_messagelabels" 
ON ( "cool_messages_label"."id" = "cool_messages_messagelabels"."label_id" ) 
WHERE "cool_messages_messagelabels"."message_id" = %s' - PARAMS = (2,)

print db.connection.queries[1]
> QUERY = u'SELECT "cool_messages_label"."id", "cool_messages_label"."text", "cool_messages_label"."type" 
FROM "cool_messages_label" INNER JOIN "cool_messages_messagelabels" 
ON ( "cool_messages_label"."id" = "cool_messages_messagelabels"."label_id" ) 
WHERE "cool_messages_messagelabels"."message_id" = %s' - PARAMS = (1,)
{% endhighlight %}

#### Using prefetch_related
{% highlight python %}
from django import db

messages = Message.objects.all().prefetch_related('labels')
getMessagesDictionary(messages)

print len(db.connection.queries)
> 2

# view content of second query
print db.connection.queries[1]['sql']
> QUERY = u'SELECT ("cool_messages_messagelabels"."message_id") 
AS "_prefetch_related_val_message_id", "cool_messages_label"."id", "cool_messages_label"."text", "cool_messages_label"."type" 
FROM "cool_messages_label" INNER JOIN "cool_messages_messagelabels" 
ON ( "cool_messages_label"."id" = "cool_messages_messagelabels"."label_id" ) 
WHERE "cool_messages_messagelabels"."message_id" 
IN (%s, %s, %s)' - PARAMS = (1, 2, 3)
{% endhighlight %}

As you can see, the naive approach above takes 3 queries to do what prefetch does in one. You can see in this important bit: `WHERE "cool_messages_messagelabels"."message_id" 
IN (%s, %s, %s)' - PARAMS = (1, 2, 3)` that it gathers data for all three message ids, instead of selecting just one at a time as highlighted in the naive approach section. Using prefetch_related handles the joining of the message data to the first query in python, so that each message doesn't need its own query. If you go look more into the [prefetch_related documentation][prefetch-related-doc], you'll be able to find some more good info on the inner workings of the method.

#### Takeaways
Using Django's `prefetch_related` method can come in handy when trying to optimize ORM queries for many-to-many relationships, especially when dealing with more complicated joins. At first glance, saving a few queries here and there might not seem like a huge deal, but they can quickly add up to affect the performance of your service. 

In dev environments, your django instance might be making queries to a local database, so round time trips aren't affected by network latency, but in the real world, network latency will add up. As the number of objects queried on increases, the number of queries with the naive approach will increase in linear time, while the number of queries with prefetching objects is bounded by constant time.

When working with Django models that have one-to-many and many-to-many relationships, be sure to use all of the built-in optimizations to your advantage - it'll save you time and energy so that you don't have to write the more simple joins over and over again.

If you have any questions or comments, please let me know below! I'm always open to clarify anything that was confusing.

[select-related-blog]: https://timmyomahony.com/blog/misconceptions-select_related-in-django/
[prefetch-related-doc]: https://docs.djangoproject.com/en/1.9/ref/models/querysets/#prefetch-related
[many-to-many-doc]: https://docs.djangoproject.com/en/1.9/topics/db/examples/many_to_many/
[django-starting]: https://www.djangoproject.com/start/
[django-through]: https://docs.djangoproject.com/en/1.9/ref/models/fields/#django.db.models.ManyToManyField.through
