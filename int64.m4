divert(-1)

This macro package provides abstraction of 64-bit registers on top
of lexical variables in Javascript, which are noticeably faster
than using any native OO abstraction mechanisms of Javascript.

In comments below, following mnemonics are used:
reg64 - name of virtual register
expr  - Javascript expression, evaluated at run time
mem   - Javascript lvalue
imm   - Constant integer expression calculated by m4 with eval

Macros starting with underscore are meant for internal use.


# _64enter(to, from, ...) - alias variables
define(`_64enter',`pushdef(`$1',`$2')dnl
pushdef(`__64frame',`popdef(`$1')popdef(`__64frame')')dnl
ifelse($3,,,`$0(shift(shift($*)))')')
# _64leave(size) - revert given number of aliases
define(`_64leave',`ifdef(`__64frame',__64frame)dnl
ifelse($1,,,ifelse(eval($1),`1',,``_64leave'(decr($1))'))')
# _64enter3reg(prefix, reg64) - create handy aliases for words
define(`_64enter3reg',`dnl
_64enter($1`l',reg64l($2),$1`h',reg64h($2),$1`t',reg64t($2))')


# Direct word access (lvalues of actual underlaying variables)
define(`reg64l',`__64$1l') # reg64l(reg64) - low word
define(`reg64h',`__64$1h') # reg64h(reg64) - high word
define(`reg64t',`__64$1t') # reg64t(reg64) - temporary variable

# var64(reg64...) - list of variables for given registers
define(`var64',`reg64l($1), reg64h($1), reg64t($1)`'dnl
ifelse($2,,,`, $0(shift($*))')')


# set64lh(reg64, expr, expr) - set register words to provided expressions
define(`set64lh',`dnl
_64enter3reg(`a',$1)dnl
ah = ifelse($3,,`0',`$3'), dnl
al = ifelse($2,,`0',`$2')`'dnl
_64leave(3)')

# load64(reg64, mem) - load value to register from some object
define(`load64',`dnl
_64enter3reg(`a',$1)dnl
ah = $2.h, dnl
al = $2.l`'dnl
_64leave(3)')

# store64(mem, reg64) - copy value from register to some object
define(`store64',`dnl
_64enter3reg(`a',$2)dnl
($1 || ($1 = {})).h = ah, dnl
$1.l = al`'dnl
_64leave(3)')


# rotl64(reg64, imm) - rotate left by constant size <= 32
define(`rotl64',`ifelse(32,eval($2), dnl
`_swap64(`$1')',`_64rotl(`$1',`$2')')')

# _swap64(reg64) - swap words in register
define(`_swap64',`dnl
_64enter3reg(`a',$1)dnl
at = ah, dnl
ah = al, dnl
al = at`'dnl
_64leave(3)')

# _64rotl(reg64, imm) - rotate left by constant size < 32
define(`_64rotl',`dnl
_64enter3reg(`a',$1)dnl
_64enter(`k',`eval($2)')dnl
at = ah >>> eval(32-k), dnl
ah <<= k, dnl
ah |= al >>> eval(32-k), dnl
al <<= k, dnl
al |= at`'dnl
_64leave(4)')


# xor64(reg64, reg64) - xor second register into the first
define(`xor64', `dnl
_64enter3reg(`a',$1)dnl
_64enter3reg(`b',$2)dnl
ah ^= bh, dnl
al ^= bl`'dnl
_64leave(6)')

# add64(reg64, reg64) - add value of second register to the first
define(`add64', `dnl
_64enter3reg(`a',$1)dnl
_64enter3reg(`b',$2)dnl
at = al >>> 16, dnl
bt = ah >>> 16, dnl
al &= 0xffff, dnl
ah &= 0xffff, dnl
at += bl >>> 16, dnl
bt += bh >>> 16, dnl
al += bl & 0xffff, dnl
ah += bh & 0xffff, dnl
at += al >>> 16, dnl
ah += at >>> 16, dnl
bt += ah >>> 16, dnl
ah &= 0xffff, dnl
al &= 0xffff, dnl
ah ^= bt << 16, dnl
al ^= at << 16`'dnl
_64leave(6)')

divert`'dnl
