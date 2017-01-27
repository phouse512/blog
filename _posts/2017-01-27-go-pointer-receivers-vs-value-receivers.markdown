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
the fields of their respective structs. Let's look at an example.

```
func (r *HttpResponse) updateStatus(new_status int) {
    r.status_code = new_status
}
```

Again, this example is very contrived and simple, but it gets the point across.
Now that we want to update the original struct in question, we need to use
a pointer receiver that passes in the struct pointer to the method.

### why?

You might be curious why the language is like this, but it makes sense once you
understand that everything in Go is passed by value. Every struct you define,
the basic types, and even things like pointers are all passed by value. In the
case of pointers, while the pointer itself is passed by value, the address that
it points to is still the same, so it allows you to modify the original object.
Once you wrap your head around that, pointer and value receivers will make
a lot of sense.

While all objects are passed by value in Go, there are a few special types that
*appear* to break this rule.

### special cases

There are a few types that appear to break the pointer and value receiver
conventions I described above. Let's look at the following example of valid
code.

```
type Sequence []int

// Methods required by sort.Interface.
func (s Sequence) Len() int {
    return len(s)
}
func (s Sequence) Less(i, j int) bool {
    return s[i] < s[j]
}
func (s Sequence) Swap(i, j int) {
    s[i], s[j] = s[j], s[i]
}
```

We see that there are three methods here for the type `Sequence`, and they
all appear to be value receivers. The first two make sense, they are returning
an int and bool calculated from the value of the `Sequence` attributes. The
third one is suspicious though - it reassigns the order of elements in the
slice, seemingly breaking the rules of value receivers.

This brings us to the special types in Go that seem to be passed by reference
no matter what. There are four types that do this, pointers, channels, maps,
and slices.

While they appear not to follow the convention that all things are passed by
value, they actually do. The reason these four types stand out is that the
data structures in these types hold pointers to a shared object underneath
the hood. For example, the `channel` type contains a pointer to a channel
descriptor, the `map` type contains a pointer to a hash table, a slice contains
pointers to an array, and a pointer points to the object it is defined with.

So even though these types are 'passed by value', a new copy of these types are
really just copies of addresses in memory. It might be a 'new' pointer,
channel, or map, but the address of its real data structure or object is the
same. Any usage of these passed-by-value pointers will still modify the
original object.

