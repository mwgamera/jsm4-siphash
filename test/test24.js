var SipHash = SipHash || require('../siphash.min.js');
var assert = assert || require('assert');

// Test vectors from reference implementation of SipHash-2-4
// https://www.131002.net/siphash/siphash24.c
var vectors = [
  [ 0xdd0e0e31, 0x726fdb47 ],
  [ 0x93dc67fd, 0x74f839c5 ],
  [ 0xd9a94f5a, 0x0d6c8009 ],
  [ 0xd7fb7e2d, 0x85676696 ],
  [ 0x277187b7, 0xcf2794e0 ],
  [ 0xcd99a68d, 0x18765564 ],
  [ 0x58fee3ce, 0xcbc9466e ],
  [ 0x8b01d137, 0xab0200f5 ],
  [ 0x9a932462, 0x93f5f579 ],
  [ 0x0ba9e4b0, 0x9e0082df ],
  [ 0x94ddb9f3, 0x7a5dbbc5 ],
  [ 0x226bada7, 0xf4b32f46 ],
  [ 0x860ee5fb, 0x751e8fbc ],
  [ 0xc0843d90, 0x14ea5627 ],
  [ 0x8e7af2ee, 0xf723ca90 ],
  [ 0x49be45e5, 0xa129ca61 ],
  [ 0x57c29bdb, 0x3f2acc7f ],
  [ 0x2cbe4794, 0x699ae9f5 ],
  [ 0x968dd39c, 0x4bc1b3f0 ],
  [ 0xa77961bd, 0xbb6dc91d ],
  [ 0x1aa2ee98, 0xbed65cf2 ],
  [ 0x2e3b67c7, 0xd0f2cbb0 ],
  [ 0xe3a33e88, 0x93536795 ],
  [ 0xcd5ccec8, 0xa80c038c ],
  [ 0xf649af94, 0xb8ad50c6 ],
  [ 0x8a85b8ea, 0xbce192de ],
  [ 0x5bbb15f3, 0x17d835b8 ],
  [ 0x076bcfad, 0x2f2e6163 ],
  [ 0xa71dc9a5, 0xde4daaac ],
  [ 0x87956571, 0xa6a25066 ],
  [ 0x5c49ef28, 0xad87a353 ],
  [ 0xd841c342, 0x32d892fa ],
  [ 0x72f27cce, 0x7127512f ],
  [ 0xf95978e3, 0xa7f32346 ],
  [ 0xbb051238, 0x12e0b01a ],
  [ 0x0fa197ae, 0x15e034d4 ],
  [ 0x0815a3b4, 0x314dffbe ],
  [ 0x29623981, 0x027990f0 ],
  [ 0x9ef40c4d, 0xcadcd4e5 ],
  [ 0x6a33735c, 0x9abfd876 ],
  [ 0x5304a7d0, 0x0e3ea96b ],
  [ 0xfc585992, 0xad0c42d6 ],
  [ 0x9bc215a9, 0x187306c8 ],
  [ 0xf3792b95, 0xd4a60abc ],
  [ 0xe4f21df2, 0xf935451d ],
  [ 0x19755787, 0xa9538f04 ],
  [ 0xf56ca510, 0xdb9acddf ],
  [ 0x5c0975eb, 0xd06c98cd ],
  [ 0x9ecba951, 0xe612a3cb ],
  [ 0xfcadaf96, 0xc766e62c ],
  [ 0x9752fe72, 0xee64435a ],
  [ 0xb245165a, 0xa192d576 ],
  [ 0x8ecb74b2, 0x0a8787bf ],
  [ 0x20b49b6f, 0x81b3e73d ],
  [ 0xa3b2ecea, 0x7fa8220b ],
  [ 0x3ca42499, 0x245731c1 ],
  [ 0x3a8d83bd, 0xb78dbfaf ],
  [ 0x322a1a0b, 0xea1ad565 ],
  [ 0xa3795013, 0x60e61c23 ],
  [ 0x46282b93, 0x6606d7e4 ],
  [ 0x5c5f91e1, 0x6ca4ecb1 ],
  [ 0x5c9625f3, 0x9f626da1 ],
  [ 0x8ef25f57, 0xe51b3860 ],
  [ 0xeb064572, 0x958a324c ]
];

// k = 00 01 02 ...
// m = (empty string)
// m = 00 (1 byte)
// m = 00 01 (2 bytes)
// m = 00 01 02 (3 bytes)
// ...
// m = 00 01 02 .. 3e (63 bytes)
var M = "";
for (var i = 0; i < vectors.length-1; i++)
  M += String.fromCharCode(i);
var k = M.substr(0, 16);

var sh24k = SipHash(2,4)(k);

var testnext = function(i) {
  if ((i |= 0) >= vectors.length)
    return console.log("Success "+i+"/"+vectors.length);
  try {
    var hx = sh24k(M.substr(0, i));
    assert.equal(hx.l|0, vectors[i][0]|0, "vector "+i+", low");
    assert.equal(hx.h|0, vectors[i][1]|0, "vector "+i+", high");
    setTimeout(function(){ testnext(i+1); }, 1);
  }
  catch (ex) {
    console.log(ex);
  }
};

console.log("Test running...");
setTimeout(testnext,0);

