all: init
	
init: moose/Makefile nesc/tools/nescc

moose/Makefile:
	@echo "*** initializing and updating moose submodules..."
	@git submodule init
	@git submodule update

nesc/tools/nescc:
	@echo "*** building NesC..."
	@(cd nesc; ./Bootstrap && ./configure && make && chmod +x tools/nescc) > .nesc.build.log 2>&1
