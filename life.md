---
layout: page
title: Life
permalink: /life/
---

<ul>
  {% for post in site.life_posts %}
    <li>
      { post.title }
    </li>
  {% endfor %}
</ul>

