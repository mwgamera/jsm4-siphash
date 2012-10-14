// vim: set ft=javascript :

// include(`int64.m4')
// include(`sipround.m4')

(function() {
  "use strict";

  /**
   * 64-bit value returned by hash function.
   * @param {number} l low word
   * @param {number} h high word
   * @constructor
   **/
  var Hashval = function(l,h) {
    this["l"] = l;
    this["h"] = h;
  };
  /** @override */
  Hashval.prototype.valueOf = function() {
    var v = this["h"] & 0x1fffff;
    v *= 0x100000000;
    v += this["l"] >>> 0;
    return v;
  };
  /** @override */
  Hashval.prototype.toString = function() {
    var p = "00000000",
        l = p + (this["l"] >>> 0).toString(16),
        h = p + (this["h"] >>> 0).toString(16);
    return h.slice(-8) + l.slice(-8);
  };

  /**
   * SipHash-c-d function factory.
   * @param {?number} c number of compression rounds
   * @param {?number} d number of finalization rounds
   * @return {function(?string): function(string): Hashval}
   **/
  var SipHash = function(c, d) {

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

    /**
     * Create pre-keyed hash function.
     * @param {Object} init precomputed initial state
     * @return {function(string): Hashval}
     **/
    var digest = function(init) {
      /**
       * @param {string} message
       * @return {Hashval}
       **/
      return function(message) {
        var var64(v0, v1, v2, v3, m),
            i, j = message.length,
            cc = c,
            cd = d,
            cw = w32le;

        load64(v0, init.v0);
        load64(v1, init.v1);
        load64(v2, init.v2);
        load64(v3, init.v3);

        message += "\x00\x00\x00\x00\x00\x00\x00".slice(j & 7);
        message += String.fromCharCode(j & 0xff);

        for (i = 0; i < message.length; i += 8) {
          set64lh(m, cw(message, i), cw(message, i+4));
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

    /**
     * @param {?string|number} key
     * @return {function(string): Hashval}
     **/
    return function(key) {
      var var64(v0, v1, v2, v3, k0, k1),
          initstate = {}, buf,
          I32MAX = 0x100000000;

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
            buf = require("crypto").randomBytes(16);
            reg64l(k0) = buf[ 0] | buf[ 1] << 8 | buf[ 2] << 16 | buf[ 3] << 24;
            reg64h(k0) = buf[ 4] | buf[ 5] << 8 | buf[ 6] << 16 | buf[ 7] << 24;
            reg64l(k1) = buf[ 8] | buf[ 9] << 8 | buf[10] << 16 | buf[11] << 24;
            reg64h(k1) = buf[12] | buf[13] << 8 | buf[14] << 16 | buf[15] << 24;
            break;
          }
          if ("undefined" !== typeof crypto && crypto.getRandomValues) {
            buf = new Uint32Array(4);
            crypto.getRandomValues(buf);
            set64lh(k0, buf[0], buf[1]);
            set64lh(k1, buf[2], buf[3]);
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

})();
