---
layout: post
title: "Practical Unit Testing with Mocks in Python3"
date: 2017-03-14 12:40:00 -0600
categories: python
comments: true
---

Over the course of writing Python in the past year, I've learned a bit
about writing effective unit-tests. Here is a collection of some of the
common use-cases I've come across while writing tests in Python.

[Unit Testing](#unit_test)

> [unit test basics](#test_basics)<br />
> [unittest.TestCase](#test_case)<br />
> [what do you test?](#what_test)<br />

[Mocking](#mocking)

> [mocking methods of a class](#mocking_methods)<br />
> [mocking out imported libraries](#mock_imports)<br />
> [mocking objects](#mock_objects)<br />

[Mock Behavior](#mock_behavior)

> returning multiple values<br />
> asserting multiple method calls<br />
> asserting exceptions thrown<br />

### Unit Testing {#unit_test}

When you're writing features and new interesting code, the last thing on your
mind is writing tests for it. When you're writing fresh code, the logic seems
simple and not worth testing at all. It's only weeks or months later when you
revisit it and make changes that you realize you have no idea what is what.
Keeping at least a surface level of test cases allows for you to make changes
without worrying about all of the business logic in your applications.

#### Unit Test Basics {#test_basics}

At the core, a unit test is just validation of the behavior of your code. You
want to know that your classes and your methods are doing what you expect. When
I was first learning how to design tests, breaking them down really helped to
design useful ones.

- *if* - this section of your unit test sets the stage for the behavior you're
  testing. For example, let's say we want to test that user creation doesn't
  create new users with the same name. The _if_ portion of this test would
  set the stage by creating a user with a given test username to check against
  later.

- *when* - this portion of your unit test actually runs the behavior that
  you want to test. In the above example, it's the equivalent of making the
  actual method call to create a new user with the username you know will fail.

- *then* - finally, you want verify that the code called above actually works.
  In our case, we should see that an exception gets thrown or a 400 Bad Request
  gets returned.

If you keep this in mind while writing your unit tests, you should end up with
sensible tests that verify useful behavior.

#### unittest.TestCase {#test_case}

The Python standard library has a built-in unit-test module that you can use
to structure your tests. The `unittest.TestCase` class can be inherited to
represent a suite of tests that relate to each other. For example, if we want to
test the behavior of a class that handles notifications, we would create
a subclass of `TestCase`.

```
class NotificationTests(unittest.TestCase):

    def setUp(self):
        # set up method that gets called before every test

    def test_notification(self):
        # a test
        self.assertEqual(True, True)
```

You can add different edge cases and test different outcomes inside a single
suite of tests. `TestCase` also comes with methods like `assertListEqual` and
others that can help make writing tests easier.

#### What Do You Test? {#what_test}

When writing unit tests, it can be easy to go a little overboard and start
testing every function in your code. While you can do this, all it ultimately
does is make testing very brittle. During refactoring, your unit tests
constantly require changing to keep them up-to-date and the value can get lost.
Write unit-tests that test the API's and interfaces between code and
that verify crucial business logic. You don't need to write tests to verify
that you are using the `range` method properly, for example.


### Mocking {#mocking}

Larger codebases have lots of moving parts and complex behaviors that need to
be tested, but not necessarily all at once. I could try to explain this in
words, but looking at a practical example may be easier.

```
def send_notifications(self, message: str):
    
    total_notifications = 0
    for user in all_users:
        if not user.is_valid():
            continue

        self.notifier.send_message(user, message)
        self.db.track_notification(user, message)
        total_notifications += 1

    return total_notifications
```

In the above example, let's say we want to test that the logic around
validating users and notification counting works as expected. We don't really
want to test the `send_message` method of `notifier`, we want to test that
independently elsewhere. This is where mocks come in handy. They allow you to
test that certain chunks of code are called/referenced without actually calling
that piece of code.

In our unit test for the method, all we care about is that `send_message`
got called a certain number of times. Whatever that method does is out of this
current tests' scope. The following line also makes an external call to
a database. Mocking also allows for you take advantage of design patterns
such as dependency injection so that you can test modularly too. Let's look at 
a few common mocking scenarios that I've run into consistently.

#### Mocking Methods of a Class {#mocking_methods}

While testing methods of a class, you might come across times where you want to
mock out the other methods of a class. We can use the `patch` method to mock
portions of a class without messing with others so you can still use them.
Here's some example code:

```
class HeartBeater(object):

    def __init__(self, service_name: str, event_name: str, db_cursor)
        self.service_name = service_name
        self.event_name = event_name
        self.active = True

    def update_timeout_flag(self, new_flag: bool):
        # some logic here that makes a database query

    def check_status(self, current_time: int):
        time_difference = current_time - self.last_received
        is_timed_out = time_difference > self.timeout

        if not self.timed_out and is_timed_out:
            self.update_timeout_flag(True)

            return (False, "some error message",)

        elif self.timed_out and is_timed_out:
            return (False, "still timed out",)
        else:
            return (True, "some happy path",)
```

While the class might not be the most sensible, let's say we want to test
the `check_status` method. Particularly we want to see that we hit the first
conditional block where `update_timeout_flag` is called. Here is how to use
`patch` to turn that call into a mock that effectively does nothing.

```
import unittest

from mock import patch
from heartbeater import HeartBeater

class HeartBeaterTest(unittest.TestCase):
    
    def setUp(self):
        # the if portion of our test
        self.hb = HeartBeater('service_test', 'test_event', db_cursor)

    @patch.object(HeartBeater, 'update_timeout_flag')
    def check_status(self, update_timeout_mock):
        # the when portion of our test
        result = self.hb.check_status(141444444)
        
        # the then portion of our test
        self.assertFalse(result[0])
        update_timeout_mock.assert_called_once_with(True)
```

As you can see, the `patch.object` decorator adds the update_timeout_mock
variable to our unit test. This is the mock object that now represents the
`update_timeout_flag` method of the class. Whenever we call that method
directly or indirectly, the mock will record how it was used so that you can
make assertions later.


#### Mocking Imported Libraries {#mock_imports}

The next case I occasionally run into deals with mocking out imported
libraries. The case I'll go over here involves mocking methods of the `sys`
package. 

```
# filename: archiver/archive.py

def archive(day, datasource):
    
    # some logic here..

    sys.stdout.write("some debug message here")

    if not_valid:
        sys.exit()
```

If we want to mock out both of these calls, we can use the `patch` decorator to
accomplish what we want. A simple test case for this code would look something
like this:

```
# filename: tests/test_archive.py

# TestCase boilerplate here..

@patch("archiver.archive.sys.exit")
@patch("archiver.archive.sys.stdout")
def test_archiver(self, stdout_mock, exit_mock):

    result = archive('03-21-2017', 23)

    stdout_mock.write.assert_called_once_with("some debug message here")
    exit_mock.assert_not_called()
```

In the unit test, you see that we create 2 distinct patches for both of the
calls we want to mock. First we mock out the `exit` method as well as the
`stdout` module of `sys`. The unit test being patched must have both in the
argument list so we can work with the mocks we've created. Mocks come in with
some handle calls that help us to verify that the mocks are being used
correctly: `sys.exit()` shouldn't be called and `stdout.write` should be
written with a debug message.

The final key point to note here is the path of the patch string for `sys`.
You'll notice that the patch is not on `@patch("sys.exit")`, this is
intentional. Because you want to mock the import call _from_ that module, you must
specify the path of the module importing and making the call,
`archiver.archive.sys.exit`. If you don't do this, your code won't fail,
but the usage of `sys` in your code won't get mocked as expected.

This happens for all sorts of imports and its very important, especially when
using libraries like `boto3` that run configuration code on import.

#### Mocking Objects {#mock_objects}

When using database cursors and other configurable objects, I often use
dependency injection patterns to make my code easier to test. I end up with
methods and classes that require a database cursor.

```
class HeartBeater(object):

    def __init__(self, db_cursor, metric_registry):
        
        self.db_cursor = db_cursor
        self.metric_registry = metric_registry

    def get_last_hb(self):
        
        query = "select * from heartbeater order by last_updated desc limit 1"
        self.db_cursor.execute(query)

        result = self.db_cursor.fetchone()
        return result
```

To test that code, we can create instances of `MagicMock` objects to inject
upon creation of the `HeartBeater` object. Let's look at an example.

```
class HeartBeaterTest(object):

    def setUp(self):
        self.mock_cursor = MagicMock()
        self.mock_metrics = MagicMock()
        self.test_hb = HeartBeater(self.mock_cursor, self.mock_metrics)

    def test_get_last_hb(self):
        
        actual_result = self.test_hb.get_last_hb()

        self.mock_cursor.assert_called_with("query string here")
```

By mocking the objects that we inject into the class instance, all of our
subsequent use of that class and its methods can be easily tested. Notice the
use of the `setUp` method also saves us time and allows for us to use the same
mock objects throughout our test suite.


