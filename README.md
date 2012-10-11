Fast SipHash for Javascript
===========================

A fast impure Javascript implementation of [SipHash](https://131002.net/siphash/).   
SipHash is a fast pseudo-random function optimized for short inputs
published by Jean-Philippe Aumasson and Daniel J. Bernstein.


Usage
-----

```javascript
var SipHash = require("./siphash.min.js");
var hash = SipHash(2,4)("somerandomkeystr")("a message");
var lsw = hash.l; // low word of the hash
var msw = hash.h; // high word of the hash
var hex = String(hash); // hexadecimal string
var uint = +hash; // 53-bit unsigned integer
```

The `SipHash` function takes two arguments corresponding to
SipHash parameters `c` and `d` as described in the
[original paper](https://www.131002.net/siphash/siphash.pdf).
They are optional and, if omitted, default of SipHash-2-4 will be used.
It returns curried SipHash-c-d function, i.e. a function that takes
a key and returns a function that maps messages to their hashes
This has obvious advantages in case you want to compute hashes for
multiple messages with the same key.

Key should be a binary string of length 16.  If a number is given,
it will be treated as 53-bit integer zero-padded to form 128-bit key.
In all other cases, a random key will be generated so you don't
have to provide it at all when it's irrelevant.
Random key is generated using `crypto.randomBytes` when running on nodejs,
`crypto.getRandomValues` when running on WebKit
and finally plain old `Math.random` when nothing better is found.

The finally returned pre-keyed function takes a binary string as its sole
argument and computes its hash.  It returns an object which has two properties:
`l` and `h` which are (signed) 32-bit integers corresponding to a low and high
words (respectively) of a 64-bit result.  When casted to string, it will yield
the value of hash in hexadecimal. Primitive value of the returned object
is an unsigned integer equal to lower 53 bits of the result (truncated hash).

### Examples

Compute test value from appendix A of SipHash paper:
```javascript
var siphash24 = SipHash(2,4);
var k = "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f";
var m = "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e";
String(siphash24(k)(m)); // returns 'a129ca6149be45e5'
```

Hash table protected from hash flooding regardless
of goodness of Javascript engine's hash (not the most efficient implementation):
```javascript
var hash = (function() {
  var h = SipHash()();
  var d = {};
  return {
    set: function(k,v) {
      return d[k+h(k)] = v;
    },
    get: function(k) {
      return d[k+h(k)];
    }
  };
})();
```

Impurity
--------

I sacrified all the good practices for sake of performance
because I thought it would be fun thing to do.  And it was!

In order to make things fast, the core of SipRound doesn't make new objects,
doesn't call any functions, and doesn't touch anything from outside the
nearest scope.  These restrictions mean that I deliberately refused to use
the usual object-oriented mechanisms provided by the language to solve the
problem of lack of 64-bit integers in Javascript.  This might seem like bad
decision, but it's very beneficial to performance on most platforms.

Of course code like this is hard to write and debug, and it could easily get
out of hand.  So I opted for a solution typical for C or assembly programmers,
i.e. I used a preprocessor.  Javascript, like most modern languages, doesn't
have it's own preprocessor and relies on native metaprogramming capabilities
instead.  However, it's quite common today to compile Javascript with tools
like Google's Closure Compiler or minify before actually using it, so why
couldn't I just put some additional preprocessing in that pipeline.

I've chosen to use good old `m4` macro processor.
It's not the most suitable processor for Javascript, note for example
that quirky ``undefine(`substr')`` line at the beginning, but,
unlike others, it is readily available just about everywhere
(it's in POSIX) and powerful enough to actually do the job easily.
The code should be compillable to plain Javascript on any Unix-like
system which provides m4.  I tested it under m4 from the Heirloom Project
and under GNU.

Reinventing the wheel
---------------------

There exist an earlier Javascript
[implementation](https://github.com/jedisct1/siphash-js)
of SipHash-2-4 which is linked from SipHash author's
[page](https://www.131002.net/siphash/#sw).
It is more readable and more adhering to programming standards than this
one (and thus, by necessity, much slower).
It has different API and it implements only SipHash with `c=2` and `d=4`
(which isn't a real limitation, but there is no real reason for it either;
unrolling loops doesn't give that much of an advantage in Javascript).
Another difference is that I didn't bother to make this one installable
via `npm`.

