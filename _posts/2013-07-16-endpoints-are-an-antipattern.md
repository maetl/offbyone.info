---
layout: post
title:  Endpoints are an anti-pattern
date:   2013-07-16 13:16:21
categories: naming
---

Microsoft, Google, and many other online service providers use the word ‘endpoint’ to describe the primary operations and resources of their platform APIs. The word is scattered everywhere you look throughout the documentation of other popular web APIs, irrespective of where they fall on the [hypermedia maturity continuum](http://www.crummy.com/writing/speaking/2008-QCon/act3.html).

[GitHub V3](http://developer.github.com/v3/) mentions endpoints and hypermedia in the same breath. Google has even modelled [entire services](https://developers.google.com/appengine/docs/python/endpoints/) on the concept.

Superficially, most web APIs can easily be described as a collection of endpoints. They have identifiers exposed as URLS which form the public surface area of their capabilities. Each URL generally defines a specific entity within the host system which can receive messages in the form of HTTP requests.

But the word endpoint itself evokes dire images of web service binding protocols instantiating service receivers; remote procedure calls aiming at parameterized targets. In short: everything that REST and hypermedia is not.

It’s no coincidence that so many of public web APIs rely on vast amounts of documentation and a myriad of HTTP clients and wrapping libraries in order to be used effectively.

Many architects of endpoints are making a fundamental mistake in assuming that what API consumers want is access to data defined as resources. But exposing APIs with a uniform interface of verbs acting on the resources isn’t enough.

What API consumers really want is access to state machines that can manipulate resources.

The missing links are the transitions between resources: relationships where the meaning of a resource is defined by reference to other resources.

If a web API doesn’t provide links that expose relationships and state transitions, following a workflow or completing a task through the API requires a manual sequence of calls that can’t be automated. The result is that consumers *need* all that detailed documentation to hard-code the API structure into their clients.

This leaves many API designers stuck in a local maxima of the hypermedia maturity heuristic. They get to the point of having nice resource URLs and uniform verbs, but fall short at cohesive link relationships amongst the resources. Without workflow models or navigable state transitions, the same business logic tends to end up duplicated on both sides of the interface. Bugs, hacks and inconsistencies proliferate.

§

Programmers are sometimes criticised by linguists and humanities scholars for wantonly invoking the [Sapir-Whorf hypothesis](https://en.wikipedia.org/wiki/Linguistic_relativity) to describe different mental models that emerge from using different programming languages. Discredited by the rise of linguistic universalism, the idea that language shapes thought is [still an open question](http://edge.org/conversation/how-does-our-language-shape-the-way-we-think), though it has had a [lasting influence](http://web.archive.org/web/20110710183418/http://elliscave.com/APL_J/tool.pdf) on the evolution of programming languages. The widespread acceptance of this idea in the software industry is largely due to the popularity of Paul Graham’s [essay about the Blub paradox](http://www.paulgraham.com/avg.html).

How does the language we use to describe web APIs influence the way we think about the design of distributed software? What does it mean to think in resources?

The word ‘endpoint’ is not mentioned once in the entire text of the [Fielding dissertation](http://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm). It’s a word that has no relevance to the domain of REST and hypermedia, and yet it’s utterly pervasive in the software industry which is moving irrevocably towards REST and hypermedia.

Perhaps this highlights a subtle cognitive dissonance where designers of web APIs prioritise operations and protocols over language and conceptual models.

Thinking in endpoints emphasises the technological envelope. Thinking in resources puts the value first.








