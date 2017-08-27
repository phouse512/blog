---
layout: post
title: "Tools and Workflows: mypy"
date: 2017-01-14 13:52:00 -0600
categories: tools mypy
comments: true
---

Reflecting on 2016, I began thinking about all of the tools I use on my
computer for programming, productivity and the web. For the tools that we use
everyday, we have lots of shortcuts and subtle habits here and there. I'm not
always conscious of the many habits I have on my computer, but I want to start
thinking about why and how I do things certain ways.

This post is the first in a series documenting the workflows and tools I use
on a regular basis. Below is a half-baked list of posts in this series (the
order and content may change):

- mypy
- vim and plugins
- ack and jq
- Todoist
- Gmail
- upstart
- jekyll
- to be continued..

Without further ado, let's get started with the first on the list, mypy.

### mypy

As I've learned and written more Python and Java, one of my biggest complaints
about Python has been the lack of any sort of typing. Quite a few bugs I've
created would've been discovered before run-time with Java, for example. There
are other times when working in large code-bases it's simply not clear
what is being passed from method to method. This is where mypy can help.

Mypy is essentially a linting tool that statically type checks your Python
code. As you write code, if you add type annotations to the classes, variables,
and other elements, mypy is able to type check and find typed errors. There are
a few different ways of adding annotations depending on Python version, but
overall they are just hints in the code. Mypy is a static analyzer, and will
never interfere with your code at run-time, it simply helps you find bugs and
understand your code.

#### Installation and Setup

To install, mypy requires Python 3.3 or later to use. You can install it by
running this:

```
python3 -m pip install mypy
```

After that, if you run `which mypy` and can see the install path, you're all
set to get started!

#### Examples and Basic Usage

Let's look at a basic example of annotating a method annotation in Python 3.
Here is an example function:

```
def say_hello(name: str) -> str:
    return "hi my friend %s" % name

say_hello("valid")
say_hello(30)
```

There are two annotations here, one for the method argument and one for the
return value. We can use mypy by running the following command: `mypy test.py`.
You'll see the following complaint from mypy:

```
test.py:5: error: Argument 1 to "say_hello" has incompatible type "int"; expected "str"
```

While the above code still runs because of the duck-typing properties of
Python, mypy loads the argument annotation and detects the mismatch. Not only
do these annotations help catch bugs, but it makes it much easier to tell what
the function actually does.

As a side-note, the syntax and usage for Python 2 is slightly different, so
check out the [documentation for Python 2.7][python2doc].

You can also set the type of a variable with an inline notation, such as shown
below:

```
class Car:
    speed = 0  # type: int
    direction_list = []  # type: List[int]

car = Car()
car.speed = 3  # this is valid
car.speed = "3"  # this is not
```

In the above, we annotate the types of two class variables using inline
annotations. When accessing and mutating class variables, mypy applies type
annotations to validate assignments as well.

Mypy comes with some built-in types, such as the `str` shown above. Here is
a brief list of the most common ones:

- `int`: integer of arbitrary size
- `float`: floating point number
- `bool`: boolean value
- `str`: unicode string
- `bytes`: 8-bit string
- `object`: Python object, the common base class
- `List[str]`: list of `str` objects
- `Dict[str, int]`: dictionary hash from `str` to `int` values
- `Iterable[bytes]`: iterable object of `bytes`
- `Sequence[float]`: sequence of `float` objects
- `Any`: dynamically typed object that can be of any type

You can use these types in method definitions, class variable annotations, and
where else you would like to annotate types. As a note, to use the types
`List`, `Dict`, `Iterable`, `Sequence` or `Any`, you need to import them from
the `typing` module. If you have already installed mypy, this won't be
a problem, and here's what an import line might look like for you:

```
from typing import Any, Dict, List
```

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

In the above, you run mypy as a python package using your cloned mypy repo so
that your changes are tested. Once you're satisfied, changes can be pushed
to your fork and you can open a pull-request from GitHub.


#### Learning More

This is a really brief introduction to mypy, and you'll be able to find much
more comprehensive explanations and documentation online. I highly recommend
the [mypy home page][homepage] as it explains a lot of the motivations and
reasoning for mypy. Just for documentation, the [mypy documentation][docs] are
incredibly helpful as well.

If you use mypy and have had good experiences with it, I would love to hear
about it!

[docs]: http://mypy.readthedocs.io/en/latest/index.html
[homepage]: http://www.mypy-lang.org/
[typeshedrepo]: https://github.com/python/typeshed
[issues]: https://github.com/python/typeshed/issues
[repo]: https://github.com/python/mypy
[fork]: https://help.github.com/articles/fork-a-repo/
[python2doc]: http://mypy.readthedocs.io/en/latest/python2.html
