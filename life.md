---
layout: page
title: Life
permalink: /life/
---
This is a collection of short, daily thoughts and memories of life. It's
inspired by journals of [Sheldon Brown][sheldon-brown] and others like him.
They are short and spur-of-the-moment thoughts, don't expect anything with
fleshed-out opinions and arguments ~

{% for post in site.life_posts %}
  <div>
    <hr />
    <i>{{ post.title }}</i><br />
    {{ post.content }}
  </div>
{% endfor %}

[sheldon-brown]: http://sheldonbrown.com/org/journal/journal-0801.html
