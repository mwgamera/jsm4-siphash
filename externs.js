// Node.js
var module;

/**
 * @param {string} module
 * @return {Object|NodejsCryptoModule}
 **/
var require = function(module) {};

/** @constructor */
var NodejsCryptoModule;
/** @param {number} size */
NodejsCryptoModule.prototype.randomBytes = function(size) {};


// WebCrypto
var crypto;
/** @param {Int8Array|Uint8Array|Int16Array|Uint16Array|Int32Array|Uint32Array} buf */
crypto.getRandomValues = function(buf) {};
