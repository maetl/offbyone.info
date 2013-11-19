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

Many programmers think of endpoints simply as HTTP accessible URLs, but other somewhat contradictory definitions exist. In the enterprise SOA world, there’s a nebulous definition of endpoint as the entry point to an implementation. In the Microsoft world, endpoint is an overloaded term, referring to both target devices for platform services and communications bindings for addressable services. [GitHub V3](http://developer.github.com/v3/) mentions endpoints and hypermedia in the same breath. Google has even modelled [entire services](https://developers.google.com/appengine/docs/python/endpoints/) on the concept. The fervid term has spread far and wide across the software industry, leaving [confusion and miscommunication](http://stackoverflow.com/questions/5034412/api-endpoint-semantics) in its wake.

In common sense terms, most web APIs can easily be described as sets of endpoints. They have identifiers exposed as URLS which form the public surface area of their capabilities. Each URL generally exposes a specific entity within the host system which can receive messages in the form of HTTP requests.

It’s no coincidence that almost all APIs designed in this way rely on vast amounts of documentation and a myriad of HTTP clients and wrapping libraries in order to be used effectively.

Such APIs seem to be constructed from the assumption that what clients want is the ability to query a data model defined as a bunch of nouns. But humans think in terms of processes and relationships; causes and effects. Most useful applications are designed around workflows, not just generic CRUD interactions.

These human habits mean that when designing a service, it’s crucial to focus on the transitions between resources that model relationships where the purpose of a resource is defined by reference to other resources.

> A truly RESTful API looks like hypertext. Every addressable unit of information carries an address, either explicitly (e.g., link and id attributes) or implicitly (e.g., derived from the media type definition and representation structure). Query results are represented by a list of links with summary information, not by arrays of object representations.
> <br><br><cite><a href="http://roy.gbiv.com/untangled/2008/rest-apis-must-be-hypertext-driven">Roy Fielding, REST APIs Must Be Hypertext Driven</a></cite>

If a service doesn’t provide links that expose activities and relationships as state transitions, following a workflow or completing a task through an API requires a manual sequence of calls that can’t be automated. The result is that consumers *need* all that detailed documentation to hard-code the API structure into their clients.

This leaves many API designers stuck in a local maxima of the hypermedia maturity heuristic. They get to the point of exposing a clean vocabulary with nice resource URLs and uniform verbs, but fall short at cohesive link relationships amongst the resources. For smaller APIs that exist within a narrow context, this is often good enough, but larger scale, longer living APIs will suffer.

When a web API doesn’t provide workflow semantics or explicitly navigable state transitions, the same logic tends to end up duplicated on both sides of its interface. Inconsistencies, hacks and bugs proliferate.

One of the reasons why so many developers misunderstand the importance of state machines in web APIs is because they’re locked in a mindset of thinking in endpoints, where the implicit structure of resources as atomic, stand-alone types with a canonical URL guides client interactions. From the perspective of mainstream object oriented languages, all problems need to be hit with the same hammer of abstract interface types with [verbs ordained by the Kingdom of Nouns](http://steve-yegge.blogspot.com.au/2006/03/execution-in-kingdom-of-nouns.html). The idea of defining a contract between systems using media types rather than interfaces is foreign and obscure.

Developers who work on APIs at this level frequently dismiss critical perspectives on REST and hypermedia as “impractical” or “academic” because they don’t believe it’s worth the effort to understand, to the point where [those who might know better](https://github.com/intridea/grape) have said that REST is [“not a very good roadmap toward building APIs for web applications”](http://www.intridea.com/blog/2010/4/29/rest-isnt-what-you-think-it-is).

To be fair, the cryptic lexicon and haughty tone of many REST advocates hasn’t helped bridge the understanding gap. Many developers struggle to translate the formal constraints of REST into something they can build that actually makes sense. People’s impression of REST, HATEOAS, hypermedia and related concepts is often limited to the context of online arguments and flame wars over terminology, correctness, and [silver bullets](http://37signals.com/svn/posts/3373-getting-hyper-about-hypermedia-apis) rather than concrete use cases and practical advice.

> We need to create an intellectual framework for API design that captures the spirit of how most popular web APIs are designed today.
> <br><br><cite><a href="https://blog.apigee.com/detail/api_design_a_new_model_for_pragmatic_rest">Brian Mulloy, A New Model for Pragmatic REST</a></cite>

I suggest that the basis of such an intellectual framework should start with the idea of workflows as state machines.

Steve Klabnik has done a fantastic job of expressing this view in [Designing Hypermedia APIs](http://www.designinghypermediaapis.com/), but there’s still a paucity of explanations and examples of web APIs that demonstrate what this means in practice.

It’s actually not very hard to find examples.

Implicit and poorly modelled state machines are observable in even the most simple web APIs based on the common CRUD pattern that frameworks like Rails, Backbone and their innumerable tutorials advocate.

Let’s look at a fictional photo blogging API that exhibits shades of this anti-pattern:

### `GET /photoblog/posts`

{% highlight javascript %}
[
   {
      "id": 3999236232,
      "caption": "My cat is not impressed",
      "thumbnail": "http://cdn.pblg/3999236232/q8ho6wborc.jpg"
      "original": "http://cdn.pblg/3999236232/l53gmg4idq.jpg"
   },
   {
      "id": 6430846656,
      "caption": "He's in the box!",
      "thumbnail": "http://cdn.pblg/6430846656/tnlcvngk9j.jpg"
      "original": "http://cdn.pblg/6430846656/ai0nef5r5n.jpg"
   }
]
{% endhighlight %}

Look at these cats! They’re so entertaining, their owners are posting thousands of photos documenting their antics. Every funny little face gets snapped, uploaded and tagged. How do we navigate through this vast array of felids?

If such an API provides pagination and filtering controls, the description of how to use them is out-of-band. Clients would have to read through documentation to discover how many results are returned by default and which parameters allow us to browse and filter the collection.

Providing a pagination parameter such as `/photoblog/posts?page=2` is convenient, but clients would need hard-coded logic to increment the page number and they still wouldn’t know when we had reached the last page in the collection. They’d also have to figure out the number of items in the collection overall to know whether or not there are actually multiple pages. Some APIs provide a separate count resource, such as `/photoblog/posts/count`. If we provided this, clients could poll in a separate request to figure out whether or not we need to navigate through multiple pages. This defies common sense. 

Thinking in endpoints has insidious consequences. It leads us to see the surface area of APIs in terms of resources being the targets of requests, and de-emphasises the underlying semantic model that the APIs are intended to provide.

When we think of this API in terms of resource types, we see the ‘collection endpoint’ as `/photoblog/posts`, the ‘post endpoint’ as `/photoblog/posts/{id}` and the ‘count endpoint’ as `/photoblog/posts/count`. The only thing clients get from this is a hard-coded interface to specific data queries through a parameterized coupling that must be known in advance.

Congratulations. We’ve just awkwardly surfaced the structure of our relational database queries through HTTP and JSON.

As a result of this design, clients of the photoblog API have to impose their own additional hand-rolled logic to work with pagination as a state machine, despite it being one of the most common use cases for working with the collection of posts.

This is the way that inconsistencies and hacks spread, bleeding through clients with the same boilerplate logic having to be re-implemented again and again in every application that integrates with the API. Multiply this by every other API that’s designed this way and the result is a vast fractal ecosystem of brittle hacks and self-similar client code.

To make it easier for clients of the photoblog, we can expose pagination explicitly as part of the resource, providing transitions between pages in a format that’s easy to navigate forward and back.

To do this, we need to treat the collection as an object that has associated metadata, rather than just a raw array of items:

### `GET /photoblog/posts?page=5`

{% highlight javascript %}
{
   "count": 199,
   "posts": [
      {
         "id": 3999236232,
         "caption": "My cat is not impressed",
         "thumbnail": {
            "href":"http://cdn.pblg/3999236232/q8ho6wborc.jpg"
         },
         "original": {
            "href":"http://cdn.pblg/3999236232/l53gmg4idq.jpg"
         }
      },
      {
         "id": 6430846656,
         "caption": "He's in the box!",
         "thumbnail": {
            "href": "http://cdn.pblg/6430846656/tnlcvngk9j.jpg"
         },
         "original": {
            "href": "http://cdn.pblg/6430846656/ai0nef5r5n.jpg"
         }
      }
   ],
   "links":{
      "self":{
         "href": "/photoblog/posts?page=5"
      },
      "next":{
         "href": "/photoblog/posts?page=6"
      },
      "prev":{
         "href": "/photoblog/posts?page=4"
      }
   }
}
{% endhighlight %}

We can take the additional step of separating navigable hyperlinks from generic scalar data types, treating URLs as objects and borrowing the `href` attribute from HTML to make the representation consistent and self-documenting.

State transitions are represented by the `links` object, borrowed from the [HAL specification](http://stateless.co/hal_specification.html). The `count` of items is treated as a first-class attribute of the resource, so that valid knowledge about the collection no longer has to be cobbled together from the results of two separate requests.

Clients can avoid having to manage incrementing and decrementing the page count and keeping track of this state. Instead, they can follow the `next` and `prev` links to transition between pages.

While pagination might be a somewhat trivial example, it demonstrates the benefits of designing the structure of an API around capabilities and state transitions, rather than plain nouns-as-data.

The pagination example is so simple that it’s easy to overlook the fact that it’s even a state machine at all, but when we do model this explicitly, a whole lot of ambiguity and complexity melts away.

---

Programmers are sometimes criticised by linguists and humanities scholars for wantonly invoking the [Sapir-Whorf hypothesis](https://en.wikipedia.org/wiki/Linguistic_relativity) to describe different mental models that emerge from using different programming languages.

Discredited by the rise of linguistic universalism, the idea that language shapes thought is [still an open question](http://edge.org/conversation/how-does-our-language-shape-the-way-we-think), though it has had a [lasting influence](http://web.archive.org/web/20110710183418/http://elliscave.com/APL_J/tool.pdf) on the evolution of programming languages. The widespread acceptance of this idea in the software industry is largely due to the popularity of Paul Graham’s [essay about the Blub paradox](http://www.paulgraham.com/avg.html).

How does the language we use to describe web APIs influence the way we think about the design of distributed software? What does it mean to think in resources?

The word ‘endpoint’ is not mentioned once in the entire text of the [Fielding dissertation](http://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm). It’s a word that has no relevance to the domain of REST and hypermedia, and yet it’s utterly pervasive in the software industry, despite the fact that in large parts, the industry is moving irrevocably towards REST and hypermedia.

Perhaps this highlights a subtle cognitive dissonance where designers of web APIs prioritise operations and protocols over language, conceptual models and business value.

Thinking in endpoints emphasises the technological envelope. Thinking in resources puts the value first.







