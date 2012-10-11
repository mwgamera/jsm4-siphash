M4=m4
NODE=nodejs
CCC=java -jar compiler.jar

siphash.js: siphash.m4 sipround.m4 int64.m4
siphash.min.js:

.SUFFIXES: .m4 .js .min.js
.m4.js:
	$(M4) $< > $@

.js.min.js: externs.js
	$(CCC) --compilation_level ADVANCED_OPTIMIZATIONS \
		--summary_detail_level 3 --warning_level VERBOSE \
		--externs externs.js \
		--js $< > $@

.PHONY: clean test

clean:
	-rm siphash*.js

test: test/test24.js siphash.js
	$(NODE) $<

