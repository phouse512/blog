---
layout: post
title: "Useful Tools #1: mypy"
date: 2017-01-14 13:52:00 -0600
categories: tools mypy
comments: true
---

Reflecting on 2016, I began thinking about all of the tools I use on my
computer for programming, productivity and the web. For tools that we use
everyday, we have lots of shortcuts and subtle habits here and there. This post
is the first in a series documenting my workflows and tools I use on a regular
basis. Below is a half-baked list of posts in this series (the order may change):

- mypy
- vim and plugins
- ack and jq
- Todoist
- Gmail
- upstart
- jekyll
- to be continued..

### mypy

As I've learned and written more Python and Java, one of my biggest complaints
about Java has been the lack of any sort of typing. Quite a few bugs I've
created would've been discovered before run-time with Java, for example. There
are other times when working in large code-bases it's simply not clear
what is being passed from method to method. This is where mypy can help.

Mypy is essentially a linting tool that statically type checks your Python
code. As you write code, if you add type annotations to the classes, variables,
and other elements, mypy is able to type check and find easy bugs. There are
a few different ways of adding annotations depending on Python version, but
overall they are just hints in the code. Mypy is a static analyzer, and will
never interfere with your code at run-time, it simply helps you find bugs and
understand your code.

#### Installation and Setup

To install, mypy requires Python 3.3 or later to use. You can install it by
running like this:

```
python3 -m pip install mypy
```

After that, if you run `which mypy` and can see the install path, you're all
set to get started!

#### Examples and Basic Usage

Let's look at a basic example

#### Contributing to Typeshed

While your own classes and methods can be annotated by yourself, it's
inevitable that you will use built-in Python classes and methods. To store
these built-in annotations, mypy has a submodule called typeshed that you can
contribute to. It stores the class and method definitions for Python's built-in
modules as well as some third-party packages.

While the majority of Python's built-in classes are stubbed out, there are
occasionally bugs and classes that don't have stubs. Check out the
[issues][issues] for the latest bugs that they need help with over there.

In terms of workflow, it can be a little tricky to test out your typeshed
changes without messing with your own mypy installation. Here's a brief
description of how I contribute to the project.

The setup is pretty simple, just clone the [mypy repo][repo] to your local
machine. Just make sure that this location is different from where you
installed mypy previously. You'll also want to [fork][fork] the [typeshed repo][typeshedrepo]
so you can set your fork as a remote to push to. Use `git
remote add <your_fork_name> <your_fork_location_url>` to set it up.

After that, it's pretty simple when it comes time to start working on an issue:

- from the `typeshed` sub-directory, checkout a new branch to identify your
  issue - `git checkout -b <branch_name>`
- make changes/fixes to typeshed stubs
- once you make your changes, it's time to run mypy using your changes, not the
  installed ones. The simplest way (as recommended by Guido himself) is to run
  mypy using a command like this: 

``` 
PYTHONPATH=~/your/path/to/your/mypy_clone python3 -m mypy -f <flags>
<your_files>
```

In the above, you run mypy as a python package using your cloned mypy repo, as
well as the changes you've made. Once you're satisfied, you can push your
changes to your fork and open a pull-request from GitHub.


#### Learning More

This is a really brief introduction to mypy, and you'll be able to find much
more comprehensive explanations and documentation online. I highly recommend
the [mypy home page][homepage] as it explains a lot of the motivations and
reasoning for mypy. Just for documentation, the [mypy documentation][docs] are
incredibly helpful as well.

[docs]: http://mypy.readthedocs.io/en/latest/index.html
[homepage]: http://www.mypy-lang.org/
[typeshedrepo]: https://github.com/python/typeshed
[issues]: https://github.com/python/typeshed/issues
[repo]: https://github.com/python/mypy
[fork]: https://help.github.com/articles/fork-a-repo/
