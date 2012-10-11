M4=m4
ED=ed
NODE=nodejs
CCC=java -jar compiler.jar

siphash.js: siphash.m4 sipround.m4 int64.m4
siphash.min.js:

.SUFFIXES: .m4 .js .min.js
.m4.js:
	$(M4) "$<" > "$@"

.js.min.js: externs.js
	$(CCC) --compilation_level ADVANCED_OPTIMIZATIONS \
		--summary_detail_level 3 --warning_level VERBOSE \
		--language_in ECMASCRIPT5_STRICT \
		--externs externs.js \
		--js "$<" --js_output_file "$@"
	-printf '%s\n' \
		'1,$$j' \
		's/.use strict.;\((function(){\)/\1"use strict";/' \
		's/case "/case"/g' \
		w q | $(ED) -s "$@"

.PHONY: clean test

clean:
	-rm siphash*.js

test: test/test24.js siphash.min.js
	$(NODE) "$<"

