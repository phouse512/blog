---
layout: page
title: Life
permalink: /life/
---
This is a collection of short, daily thoughts and memories of life. It's
inspired by journals of [Sheldon Brown][sheldon-brown] and others like him.

{% for post in site.life_posts %}
  <div>
    <i>{{ post.title }}</i><br />
    {{ post.content }}
    <hr />
  </div>
{% endfor %}

[sheldon-brown]: http://sheldonbrown.com/org/journal/journal-0801.html
