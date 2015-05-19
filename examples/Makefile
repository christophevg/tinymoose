EXAMPLES=$(patsubst %/,%,$(wildcard */))

all: $(addsuffix .example,${EXAMPLES})

%.example: %
	@echo "!!! building example $<"
	@(cd $<; make clean hex > .$<.log 2>&1 || (cat .$<.log && false))

clean: $(addsuffix .clean,${EXAMPLES})

%.clean: %
	@echo "!!! cleaning example $<"
	@(cd $<; make clean)
