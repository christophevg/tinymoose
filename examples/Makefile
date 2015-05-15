EXAMPLES=$(patsubst %/,%,$(wildcard */))

all: $(addsuffix .example,${EXAMPLES})

%.example: %
	@echo "!!! building example $<"
	@(cd $<; make hex > .$<.log 2>&1 || (cat .$<.log && false))
