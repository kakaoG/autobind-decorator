BIN = ./node_modules/.bin
TESTS = $(shell find ./src -name '*-test.js')
SRC = $(shell find ./src -name '*.js')
LIB = $(SRC:./src/%=lib/%)

BABEL_OPTS = \
	--presets=es2015 \
	--plugins=transform-decorators-legacy

build:: $(LIB)

build-test:: build
	@$(BIN)/mochify \
		--phantomjs $(BIN)/phantomjs \
		$(TESTS:./src/%=./lib/%)

test::
	@$(BIN)/mochify \
		--transform [ babelify $(BABEL_OPTS) ] \
		--phantomjs $(BIN)/phantomjs \
		$(TESTS)

ci::
	@$(BIN)/mochify \
		--watch \
		--transform [ babelify $(BABEL_OPTS) ] \
		--phantomjs $(BIN)/phantomjs \
		$(TESTS)

lint::
	@$(BIN)/eslint $(SRC)

version::
	@$(BIN)/standard-version

release: clean build build-test lint version

publish:
	git push --tags origin HEAD:master
	npm publish

lib/%.js: src/%.js
	@echo "building $@"
	@mkdir -p $(@D)
	@$(BIN)/babel $(BABEL_OPTS) --source-maps-inline -o $@ $<

clean:
	@rm -rf lib/
