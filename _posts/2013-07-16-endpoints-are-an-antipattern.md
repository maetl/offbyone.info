---
layout: post
title:  "Don’t Think in Endpoints"
categories: language
tags: ["API Design", "Hypermedia", "Cognitive Dissonance"]
image:
  feature: dont-think-in-endpoints.jpg
  credit: Alexander Klink
  creditlink: http://commons.wikimedia.org/wiki/File:603qm_Wegweiser.jpg
---

## What happens when we eliminate the word ‘endpoint’ from the process of designing and documenting web APIs?

The word ‘endpoint’ is scattered everywhere you look throughout the descriptions of popular web APIs, irrespective of where they fall on the [hypermedia maturity continuum](http://www.crummy.com/writing/speaking/2008-QCon/act3.html).

In common usage, an endpoint is an addressable resource—usually an HTTP accessible URL—but other somewhat contradictory definitions exist. In the enterprise SOA world, there’s a nebulous definition of endpoint as the entry point to an implementation. In the Microsoft world, endpoint is an overloaded term, referring to both target devices for platform services and communications bindings for addressable services. [GitHub V3](http://developer.github.com/v3/) mentions endpoints and hypermedia in the same breath. Google has even modelled [entire services](https://developers.google.com/appengine/docs/python/endpoints/) on the concept. The fervid term has spread far and wide across the software industry, leaving [confusion and miscommunication](http://stackoverflow.com/questions/5034412/api-endpoint-semantics) in its wake.

Most web APIs can easily be described as sets of endpoints. They have identifiers exposed as URLS which form the public surface area of their capabilities. Each URL generally exposes a specific entity within the host system which can receive messages in the form of HTTP requests.

It’s no coincidence that almost all APIs designed in this way rely on vast amounts of documentation and a myriad of HTTP clients and wrapping libraries in order to be used effectively.

Such APIs seem to be constructed from the assumption that what clients want is the ability to query data defined as resources. But humans think in terms of processes and relationships; causes and effects. Most useful applications are designed around state machines that can meaningfully manipulate resources, not just generic CRUD interactions.

These human habits mean that when designing a service, it’s crucial to focus on the transitions between resources and model relationships where the meaning of a resource is defined by reference to other resources. Exposing data with a uniform interface of verbs acting on nouns isn’t enough. 

If a service doesn’t provide links that expose activities and relationships as state transitions, following a workflow or completing a task through an API requires a manual sequence of calls that can’t be automated. The result is that consumers *need* all that detailed documentation to hard-code the API structure into their clients.

This leaves many API designers stuck in a local maxima of the hypermedia maturity heuristic. They get to the point of exposing a clean vocabulary with nice resource URLs and uniform verbs, but fall short at cohesive link relationships amongst the resources.

When an API doesn’t provide workflow semantics or explicitly navigable state transitions, the same logic tends to end up duplicated on both sides of its interface. Inconsistencies, hacks and bugs proliferate.

Implicit and poorly modelled state machines are observable in even the most simple web APIs based on the common CRUD pattern that frameworks like Rails, Backbone and their innumerable tutorials advocate.

Let’s look at a fictitious photo blogging API that follows this pattern, representing collections as JSON arrays containing an object for each posted item:

> GET /photoblog/posts

{% highlight javascript %}
[
   {
      "id":3999236232,
      "caption":"My cat is not impressed",
      "thumbnail":"http://cdn.pblg/3999236232/q8ho6wborc.jpg"
      "original":"http://cdn.pblg/3999236232/l53gmg4idq.jpg"
   },
   {
      "id":6430846656,
      "caption":"He's in the box!",
      "thumbnail":"http://cdn.pblg/6430846656/tnlcvngk9j.jpg"
      "original":"http://cdn.pblg/6430846656/ai0nef5r5n.jpg"
   }
]
{% endhighlight %}

These cats are so entertaining that their owners are posting thousands of photos documenting their antics. Every funny little face and gesture gets snapped, uploaded and tagged. How do we navigate through this vast array of cats?

If such an API provides pagination and filtering controls, the knowledge of how to use them is out-of-band. We’d have to read through its documentation to discover how many results are returned by default and which parameters allow us to browse and filter the collection.

Using a pagination parameter such as `/photoblog/posts?page=2` is convenient, but we’d need hard-coded logic to increment the page number and we still wouldn’t know when we had reached the last page in the collection. We’d also have to figure out the number of items in the collection overall to know whether or not there are actually multiple pages. If the API provides a count resource, such as `/photoblog/posts/count`, we could poll this separately to figure out whether or not we need to navigate through multiple pages.

Thinking in endpoints has insidious consequences. It leads us to think about the surface area of our API in terms of resources being the targets of requests, and de-emphasises the underlying semantic model that the API is intended to provide. In the case of our photoblog, the collection endpoint is `/photoblog/posts`, the item endpoint is `/photoblog/posts/{id}` and the count endpoint is `/photoblog/posts/count`. The only thing we get from this is a definition of tabular data in terms of requests and responses. 

Congratulations. We’ve just duplicated the structure of our relational database in HTTP and JSON.

As a result of this design, clients of the photoblog API have to impose their own additional hand-rolled logic to work with pagination as a state machine, despite this being one of the most common use cases for working with the collection of posts.

This is the way that inconsistencies and hacks spread, bleeding through client code with the same boilerplate logic having to be re-implemented again and again in every application that integrates with the API.

To make it easier for clients, we can expose pagination explicitly as part of the resource, providing transitions between pages in a format that’s easy to navigate forward and back.

To do this, we need to treat the collection as an object that has associated metadata, rather than just a raw array of items:

> GET /photoblog/posts?page=5

{% highlight javascript %}
{
   "count":199,
   "posts":[
      {
         "id":3999236232,
         "caption":"My cat is not impressed",
         "thumbnail":{
            "href":"http://cdn.pblg/3999236232/q8ho6wborc.jpg"
         },
         "original":{
            "href":"http://cdn.pblg/3999236232/l53gmg4idq.jpg"
         }
      },
      {
         "id":6430846656,
         "caption":"He's in the box!",
         "thumbnail":{
            "href":"http://cdn.pblg/6430846656/tnlcvngk9j.jpg"
         },
         "original":{
            "href":"http://cdn.pblg/6430846656/ai0nef5r5n.jpg"
         }
      }
   ],
   "links":{
      "self":{
         "href":"/photoblog/posts?page=5"
      },
      "next":{
         "href":"/photoblog/posts?page=6"
      },
      "prev":{
         "href":"/photoblog/posts?page=4"
      }
   }
}
{% endhighlight %}

We can take the additional step of separating navigable hyperlinks from generic scalar data types, treating URLs as objects and borrowing the `href` attribute from HTML to make the representation consistent and self-documenting.

State transitions are represented by the `links` object, borrowed from the [HAL specification](http://stateless.co/hal_specification.html). The `count` of items is treated as a first-class attribute of the resource, so that valid knowledge of the collection’s state no longer has to be cobbled together from the results of two separate requests.

Clients no longer have to manage incrementing and decrementing the page count and keeping track of this. They can just follow the `next` and `prev` links to transition between pages.

While pagination might be a somewhat trivial example, it demonstrates the benefits of designing the structure of an API around capabilities and state transitions, rather than plain data.

The pagination example is so simple that it’s easy to overlook the fact that it’s even a state machine at all, but when we do model this explicitly, a whole lot of ambiguity and complexity melts away.

--

Programmers are sometimes criticised by linguists and humanities scholars for wantonly invoking the [Sapir-Whorf hypothesis](https://en.wikipedia.org/wiki/Linguistic_relativity) to describe different mental models that emerge from using different programming languages. Discredited by the rise of linguistic universalism, the idea that language shapes thought is [still an open question](http://edge.org/conversation/how-does-our-language-shape-the-way-we-think), though it has had a [lasting influence](http://web.archive.org/web/20110710183418/http://elliscave.com/APL_J/tool.pdf) on the evolution of programming languages. The widespread acceptance of this idea in the software industry is largely due to the popularity of Paul Graham’s [essay about the Blub paradox](http://www.paulgraham.com/avg.html).

How does the language we use to describe web APIs influence the way we think about the design of distributed software? What does it mean to think in resources?

The word ‘endpoint’ is not mentioned once in the entire text of the [Fielding dissertation](http://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm). It’s a word that has no relevance to the domain of REST and hypermedia, and yet it’s utterly pervasive in the software industry, despite the fact that in large parts, the industry is moving irrevocably towards REST and hypermedia.

Perhaps this highlights a subtle cognitive dissonance where designers of web APIs prioritise operations and protocols over language, conceptual models and business value.

Thinking in endpoints emphasises the technological envelope. Thinking in resources puts the value first.







