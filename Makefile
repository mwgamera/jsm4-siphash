M4=m4
NODE=nodejs

siphash.js: siphash.m4 sipround.m4 int64.m4

.SUFFIXES: .m4 .js .min.js
.m4.js:
	$(M4) $< > $@

.PHONY: clean test

clean:
	-rm *.js

test: test/test24.js siphash.js
	$(NODE) $<

