divert(-1)

# The SipHash compression function
# SipRound(reg64, reg64, reg64, reg64)
define(`SipRound',
`dnl
add64( $1, $2), add64( $3, $4), dnl
rotl64($2, 13), rotl64($4, 16), dnl
xor64( $2, $1), xor64( $4, $3), dnl
rotl64($1, 32), dnl
dnl
add64( $3, $2), add64( $1, $4), dnl
rotl64($2, 17), rotl64($4, 21), dnl
xor64( $2, $3), xor64( $4, $1), dnl
rotl64($3, 32)')

divert`'dnl
