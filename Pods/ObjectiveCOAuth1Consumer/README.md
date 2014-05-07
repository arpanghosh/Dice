ObjectiveCOAuth1Consumer
=====

Release 0.0.1

An Objective-C OAuth1 Library (source obtained from: https://code.google.com/p/oauthconsumer/wiki/UsingOAuthConsumer) packaged as a Framework, specifically for use with the Yelp v2.0 API.

Yelp requires a weird variant of 2-legged OAuth from a client trying to access it's API. The API has no user-centric entities and hence no need for 3-legged OAuth (to obtain a user's access token). However, the API still needs all requests to be signed with the CLIENT's consumer key, consumer secret, token and token secret. This framework is flexible enough to accomodate this behavior.
