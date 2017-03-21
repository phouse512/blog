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

Mocking

> mocking methods of a class<br />
> mocking out imported libraries<br />
> mocking objects<br />

Mock Behavior

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
constantly require changing to keep them up-to-date and the value can begin to
get lost. Write unit-tests that test the API's and interfaces between code and
that verify crucial business logic. You don't need to write tests to verify
that you are using the `range` method properly, for example.
