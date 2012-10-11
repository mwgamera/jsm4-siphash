// vim: set ft=javascript :

// include(`int64.m4')
// include(`sipround.m4')
// undefine(`substr')

var SipHash = function(c, d) {
  "use strict";

  // defaults to SipHash-2-4
  c >>>= 0; c = c || 2;
  d >>>= 0; d = d || 4;

  // load 32-bit value from string, litte-endian
  var w32le = function(bstr, i) {
    return bstr.charCodeAt(i) |
      bstr.charCodeAt(i+1) <<  8 |
      bstr.charCodeAt(i+2) << 16 |
      bstr.charCodeAt(i+3) << 24;
  };

  // returned type for computed values (64-bit)
  /** @constructor */
  var Hashval = function(l,h) {
    this["l"] = l;
    this["h"] = h;
  };
  Hashval.prototype.valueOf = function() {
    var v = this["h"] & 0x1fffff;
    v *= 0x100000000;
    v += this["l"] >>> 0;
    return v;
  };
  Hashval.prototype.toString = function() {
    var p = "00000000";
    var l = p + (this["l"] >>> 0).toString(16);
    var h = p + (this["h"] >>> 0).toString(16);
    return h.substr(h.length-8) + l.substr(l.length-8);
  };

  // compute configured and keyed hash of message
  var digest = function(init) {
    return function(message) {
      var var64(v0, v1, v2, v3, m);
      var i, j = message.length;
      var cc = c, cd = d;
      var w = w32le;

      load64(v0, init.v0);
      load64(v1, init.v1);
      load64(v2, init.v2);
      load64(v3, init.v3);

      message += "\x00\x00\x00\x00\x00\x00\x00".substr(j & 7);
      message += String.fromCharCode(j & 0xff);

      for (i = 0; i < message.length; i += 8) {
        set64lh(m, w(message, i), w(message, i+4));
        xor64(v3, m);
        for (j = 0; j < cc; j++)
          SipRound(v0, v1, v2, v3);
        xor64(v0, m);
      }

      reg64l(v2) ^= 0xff;

      for (j = 0; j < cd; j++)
        SipRound(v0, v1, v2, v3);

      xor64(v0, v1);
      xor64(v2, v3);
      xor64(v0, v2);

      return new Hashval(reg64l(v0), reg64h(v0));
    };
  };

  return function(key) {
    var I32MAX = 0x100000000;

    var var64(v0, v1, v2, v3, k0, k1);
    var initstate = {};

    switch (typeof key) {
      case "string":
        set64lh(k0, w32le(key, 0), w32le(key, 4));
        set64lh(k1, w32le(key, 8), w32le(key,12));
        break;
      case "number":
        set64lh(k0, 0 | key, 0 | key / I32MAX);
        set64lh(k1, 0, 0);
        break;
      default: // random key
        if ("function" === typeof require && require("crypto")) {
          var buf = require("crypto").randomBytes(16);
          reg64l(k0) = buf[ 0] | buf[ 1] << 8 | buf[ 2] << 16 | buf[ 3] << 24;
          reg64h(k0) = buf[ 4] | buf[ 5] << 8 | buf[ 6] << 16 | buf[ 7] << 24;
          reg64l(k1) = buf[ 8] | buf[ 9] << 8 | buf[10] << 16 | buf[11] << 24;
          reg64h(k1) = buf[12] | buf[13] << 8 | buf[14] << 16 | buf[15] << 24;
          break;
        }
        if ("undefined" !== typeof crypto && crypto.getRandomValues) {
          var a32 = new Uint32Array(4);
          crypto.getRandomValues(a32);
          set64lh(k0, a32[0], a32[1]);
          set64lh(k1, a32[2], a32[3]);
          break;
        }
        set64lh(k0, 0 | I32MAX*Math.random(), 0 | I32MAX*Math.random());
        set64lh(k1, 0 | I32MAX*Math.random(), 0 | I32MAX*Math.random());
    }

    set64lh(v0, 0x70736575, 0x736f6d65);
    set64lh(v1, 0x6e646f6d, 0x646f7261);
    set64lh(v2, 0x6e657261, 0x6c796765);
    set64lh(v3, 0x79746573, 0x74656462);

    xor64(v0, k0);
    xor64(v1, k1);
    xor64(v2, k0);
    xor64(v3, k1);

    store64(initstate.v0, v0);
    store64(initstate.v1, v1);
    store64(initstate.v2, v2);
    store64(initstate.v3, v3);

    return digest(initstate);
  };
};

"undefined" !== typeof module && (module.exports = SipHash) || (window["SipHash"] = SipHash);
