---
layout: post
title: "Tools and Workflows: pylint and makefiles"
date: 2017-08-27 13:52:00 -0600
categories: tools pylint makefiles
comments: true
---


As [amper][amper] is looking to [grow][grow] and our codebases expand, one
area of concern I have has been making sure to maintain code quality while
pushing code quickly. My first area of attack has been looking at our
high-touch areas, and in particular our Django api.

Today I want to describe how we set up our project workflow to make consistency
and quality checks a first-class component in our process. First I'll go over
our use of [pylint][pylint], then discuss how we use [Makefiles][make] to
simplify command line usage. Finally, I'll show how we use [git hooks][hooks] to
tie all of our tools into the version-control process.

### pylint and mypy for quality

I'm a big fan of both pylint and mypy but today I'll be going over pylint as
I've gone over [mypy][mypy] in a [previous post][prev_mypy]. There's a
bunch of [documentation][pylint_docs] about pylint so I won't be mirroring that
here, but briefly here's a list of things that it helps us do:

- keep consistent coding standards by following [pep8][pep8]
- point out areas that need to be refactored because of code duplication
- detect errors with interface implementations
- requires docs for functions and modules

Pylint has many checks and rules that it looks for, but the nice
thing is that it is completely configurable to your liking. You can easily
generate a `pylintrc` by running `pylint --generate-rcfile`. That will output
to stdout and you can redirect it to wherever you'd like, although the
default for most projects is `.pylintrc` in the root directory.

In your `pylintrc` you may configure rules and checks, as well as specify
warnings to ignore, etc. You can even write [custom checkers][custom] and
plugins if your company or project so requires, although we've never needed
it.

You might run into scenarios where there are rules that you need to override
because of your constraints. A common one for us when using Django is when
defining views with the `request` parameter. Every view doesn't necessarily
require using it but we like to keep it there so that it's easy to tell it's
available for future modifications. Pylint also comes with some handy notation
that you can use to disable specific roles locally or at the file-level.

```
@auth_user
def list_users(request, **kwargs) -> HttpResponse:  # pylint: disable=unused-argument
    # some view processing here

    return HttpResponse(status_code=200)
```

To disable a lint error, you can either use the string representation as shown
above, or you can use the code representation. The code representation can come
in handy when you have multiple warnings you want to disable, but usually I err
on the side of being verbose when I can. You can find a list of codes at this
[site][pylint_codes], but as a heads-up, they don't include the string
representation pairing, just a brief description for each one. As a final note
for disabling errors, think carefully about what kind of coding practices you
want to encourage or discourage, it adds up in the long-term.

Before we move on, I'll put in a brief plug for [pycodestyle][pycs]. It also
lints your code but specifically looks for compliance with `pep8`. We use both
in tandem since it can sometimes find small issues that pylint doesn't, and
vice versa. Overall, we more heavily lean on pylint.

### Makefiles for simplicity

Now that we have the tools to help lint and type check our code, the next step
is to simplify our build process. At this point, there are quite a few commands
that we are keeping track of if you're developing on this project. There 
`pip install`, our linting commands, unit-tests, integration-tests, etc.
Instead of writing some custom bash scripts to handle it, we use Makefiles to
simplify things.

Make is a build automation tool that has been around since the 70s, and is by
default installed on Unix systems. Because it is cross-platform and so commonly
used, it made sense for us to use to to automate our local automation tasks as
well.

For those of you unfamiliar with makefiles, they are pretty simple to
understand. Let's look at their basic syntax below. We define targets that
label the name of the command we're running, next we then list any other
dependencies (other targets elsewhere in your makefile) that should get run
before executing the system commands underneath it.

```
# format
target: dependencies
    system commands
```

Let's look at a real example of a Makefile we use to run for our Django
codebase.

```
install:
    pip install -r requirements.txt

lint:
    python -m pylint --rcfile=.pylintrc module1/ module2/ module3/ -r n && \
    python -m pycodestyle module1/ module2/ module3/ --max-line-length=120

test:
    python manage.py test --testrunner=project.testrunner.NoDbTestRunner
```

We'll add to this configuration a little bit later, but for now it's pretty
straightforward and simple. We have a `make install` command we use to install
our dependencies. Next we chain multiple linting calls using bash's `&&`
operator. This chains the two calls and will only run the second linting
command if the first successfully exits with status 0 (see more [here][chain]).
Finally we have a test command that calls the Django unit tests using our own
custom test runner. 

This makes it that much easier to remember, even when the
commands underneath are actually quite complicated. Make files allso allow for
you to keep consistent build language throughout your organization, regardless
of the languages or technologies beneath the hood.

We'll be adding a few more commands later as we look at how to integrate git
hooks into our flow.

### git hooks for integration

The final step in improving our workflow is making it second-thought and
integrated into existing processes. The sooner we can catch style violations
and potential errors, the better. In our workflow, we use git hooks, and
specifically `pre-commit` hooks. Hooks get triggered on actions, so in our
pre-commit case, an action is called before a commit gets created.

At the core, hooks are bash scripts that you can configure to run whatever
you'd like. In our case, our pre-commit bash script runs targets in our
Makefile to lint and unit-test. Let's look at our `pre-commit.sh` file:

```
#!/bin/sh
red="\033[0;31m"
yellow="\033[1;33m"
green="\033[1;32m"
reset="\033[0m"

read -a changed_files <<< $(git diff --cached --name-only --raw)

# call command
make pre-commit


# now if tests failed let's abort commit by "exit 1"
# if not, congratulations, commit is now in Git
testResults=$?
if [ $testResults -eq 1 ] || [ $testResults -eq 2 ]
then
    echo -e "${red}\nTests FAILED\n\ncommit ABORTED${reset}"
    exit 1
else
    echo -e "${green}\nOK\n${reset}"
fi
exit 0
```

This is a simplified version, but let's look at the important aspects of this
script. There is some boilerplate at the top, but after that we call the
`pre-commit` command from our Makefile. Following that, `testResults` stores
the status code output from its execution, and depending on the result, either
exits successfully (status 0), or with an error (status 1). If it outputs with
an error, `git` will abort and prevent a commit from being made. If `make
pre-commit` does not error out, our commit gets created normally.

You may find that you need to customize your bash script differently, but
remember that you need to exit with a status code indicating success/error.

The next step is to configure your git repository to use the bash script when
making commits. First, look in your `.git` directory, inside there is a sub-directory
`hooks` that stores some sample scripts. To 'enable' a hook script, all you
need to do is place a script in the `.git/hooks` directory with the name of the
hook. In our case, we want a file like this: `.git/hooks/pre-commit`.

When we set this up for ourself, we also wanted to keep the pre-commit script
in version control so we could make changes over time. We keep
a `pre-commit.sh` bash script in the root of a directory, and then use
[symlinks][sym] to create a reference in the `.git/hooks` repo to our script.

To get started, the symlink only needs to be created the first time when
cloning the repo. To make this easy for ourselves, we have a make target that
automatically creates the symlink as shown below:

```
setup-hooks:
    cd .git/hooks && \
    ln -s -f ../../pre-commit.sh ./pre-commit
```

When setting the project up on a new machine, `make setup-hooks` needs to be
run once, then the project is all set[^1]. Upon following commits, our linting
and testing code will always get run.

In our case, we also added a make target specifically called `pre-commit`. This
combines all the target dependencies we want to check on commit into one.

```
pre-commit: install lint test
    echo "All set to commit."
```

It's incredibly simple, and all it does is cause 3 of our previous target
commands to be built successfully before echo'ing a success. With some pretty
simple scripting and some git/make magic, our workflow is done! It doesn't
matter if you forget to lint some code before checking it in - git won't even
let you commit until things pass on your machine.

---

With that, our local development workflow is complete. Unit-testing,
type-checking and linting help us to be more confident that our code is
working as expected. Makefiles allow for us to use these complex tools really easily
without having to remember complicated build commands. Finally, git pre-commit
hooks are the gatekeeper for submitting code that doesn't pass at least basic
checks, saving time for everyone else on your team.


---

[^1]: If you're curious about the strange relative pathing of this `ln` call, it's because the `pre-commit` script is called from the `.git/hooks` directory, so it needs to know the path of our script from `.git/hooks` and not the root of our repository.

[amper]: https://www.amper.xyz/
[mypy]: http://mypy-lang.org/
[pylint]: https://www.pylint.org/
[make]: https://en.wikipedia.org/wiki/Makefile
[hooks]: http://githooks.com/
[grow]: https://angel.co/amper-technologies/jobs
[pylint_docs]: https://pylint.readthedocs.io/en/latest/
[pep8]: https://www.python.org/dev/peps/pep-0008/
[custom]: https://pylint.readthedocs.io/en/latest/how_tos/custom_checkers.html
[pylint_codes]: http://pylint-messages.wikidot.com/all-codes
[pycs]: http://pycodestyle.pycqa.org/en/latest/
[chain]: https://unix.stackexchange.com/questions/187145/whats-the-difference-between-semicolon-and-double-ampersand
[sym]: https://en.wikipedia.org/wiki/Symbolic_link
[prev_mypy]: http://www.phizzle.space/tools/mypy/2017/01/14/tools-workflows-mypy.html
