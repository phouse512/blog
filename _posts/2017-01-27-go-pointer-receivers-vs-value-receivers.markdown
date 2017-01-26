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

#### pointer receivers
the example of a pointer receiver

#### value receivers

a value receiver

#### putting it together

here is an example of code with everything in one

### special cases

let's talk about slices, maps, and more!!
