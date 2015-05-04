all: moose/Makefile
	@echo "Take a look at the src folder and try building an example."

moose/Makefile:
	@echo "*** initializing and updating moose submodule"
	@git submodule init
	@git submodule update
