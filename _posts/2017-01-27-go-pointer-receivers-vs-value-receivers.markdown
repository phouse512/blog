---
layout: post
title: "Pointer Receivers vs. Value Receivers in Go"
date: 2017-01-27 17:28:00 -0600
categories: golang
comments: true
---

If you program in Go at all, you know that Go doesn't support traditional
classes that you might find in other OOP languages. Rather, it contains
`structs`, typed collections of fields. Go also supports defining methods on
your struct types, similar to traditional class methods in other langauges.

There are two types of methods that you can define on structs: pointer
receivers and value receivers. When I was first learning Go, I struggled
with this concept until it was clearly laid out for me, so that's what
I'll explain today.

### structs and receivers in go

Before we get started, let's define an example struct that we can reference
throughout this post.

```
type HttpResponse struct {
    status_code int
    headers map[string]string
    body string
}
```

We have a simple `HttpResponse` struct with a status code, a map for header
key-value pairs, and the body of the response. Let's move on to looking at
how value receivers work.

#### value receivers

Let's define a method that outputs a boolean value, depending on whether or not
a `HttpResponse` object was successful.

```
func (r HttpResponse) validResponse() boolean {
    if r.status_code < 300 {
        return true
    }
    return false
}
```

The method is simple, but the important thing to take note of here is the
section of code `func (r HttpResponse)`. This means that the struct is being
passed by value into the method. When a method is a value receiver, it means
that you *cannot modify the struct fields* ** because the struct is being passed
by value. This means that you can use value receivers when you want to use the
fields of a struct but not modify them.

** barring special types, which we'll discuss further on.

#### pointer receivers

If value receivers don't let you modify the struct itself, its intuitive that
pointer receivers are the opposite. Pointer receivers allow for you to modify
the fields of its respective struct. Let's look at an example.

```
func (r *HttpResponse) updateStatus(new_status int) {
    r.status_code = new_status
}
```

Again, this example is very contrived and simple, but it gets the point across.
Now that we want to update the original struct in question, we need to use
a pointer receiver that passes in a pointer to the method.

### why?

You might be curious why Go is like this, but it makes sense once you
understand that everything in Go is passed by value. Every struct you define,
the basic types, and even things like pointers are all passed by value. In the
case of pointers, while the pointer itself is passed by value, the address that
it points to is still the same, so it allows you to modify the original object.
Once you wrap your head around that, pointer and value receivers will make
a lot of sense.

While all objects are passed by value in Go, there are a few special types that
*appear* to break this rule.

### special cases

let's talk about slices, maps, and more!!
