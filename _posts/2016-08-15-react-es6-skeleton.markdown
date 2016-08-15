---
layout: post
title: "A simple React and ES6 project"
date: 2016-08-15 8:56:49 -0600
categories: javascript react webpack 
comments: false
---

Recently I began working on a web project that I wanted to use React and ES6
for, and I started going through the [beginner tutorials][react-tut] at the
React homepage. While they are great for starting, you embed your JS code
directly in the page, and I couldn't find out much info there on how to start
bundling React with webpack. If you [google react es6 skeletons][google],
you'll find a lot of options, and some pretty good ones as well. Unfortunately,
I am a Javascript novice and many of the norms set up in some of these projects
were foreign to me, so I wanted something slightly more barebones. I spent
a short evening bundling up my work so that someone who is coming from 
other programming backgrounds will be able to start quickly. 
You can find a link to the skeleton repo [here][my-skel]. It uses
[webpack][webpack] to bundle your js, and it also includes Bootstrap for ease
of use. The build/run commands are all done using the npm task runner, and not
an external tool that requires another config. All of the relevant info you
need should be highlighted in the README, but let me know if there is anything
missing.

[google]: https://www.google.com/#q=react+es6+skeleton
[webpack]: https://webpack.github.io/
[my-skel]: https://github.com/phouse512/react-es6-skeleton
[react-tut]: https://facebook.github.io/react/docs/tutorial.html
