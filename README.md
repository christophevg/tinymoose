# TinyMoose

An experiment on integrating [Moose](https://github.com/christophevg/moose) and [TinyOS](https://github.com/tinyos/tinyos-main)  
Christophe VG <contact@christophe.vg>  
[https://github.com/christophevg/tinymoose](https://github.com/christophevg/tinymoose)

## Introduction

So far, I've been implementing my own hardware abstraction layer on top of the
Atmel family of mcu's, called [Moose](https://github.com/christophevg/moose).
With this experiment, I'm trying to run TinyOS on my own hardware, implementing
what's missing using Moose, like the XBee networking support.

## Rationale

The reason for this unholy matrimony originates from another experiment, where
I want to compare the optimisations of TinyOS to those of the Functional Code
Fusion, developed in [foo-lang](https://github.com/christophevg/foo-lang). To
do this comparison, I want comparable versions of the software running on the
same hardware. The initial comparison was agains hand-written code, now I want
to compare to NesC/TinyOS, so I need to layer TinyOS on top of Moose, creating
TinyMoose ;-)

## Getting started

TinyMoose, builds on TinyOS and Moose. Both projects are on GitHub, and are
included in this repo as submodules. The top-level Makefile ensures that
everything is initialized, updated and built as needed.

```bash
$ make
*** initializing and updating submodules...
*** building NesC...
```

If building NesC fails, check `.nesc.build.log`, which contains all output.

Running the command a second time, doesn't do any harm, `make` will tell you
all is up to date ;-)

```bash
$ make
make: `all' is up to date.
```

## Examples

Every example builds from a single `make` command. It uses `nesc1` to generate
the single C file that contains everything. Next, it uses Moose's build
infrastructure to build it.

The output of `nesc1` is caught in `.nesc.generation.log`.

### Hello TinyMoose

```bash
$ cd src/hello/
$ make
*** constructing build/main.c for Hello example...
*** adding Makefile to build Hello example...
*** building Hello example...
--- compiling main.c
../../tinyos-main/tos/chips/atm128/atm128hardware.h:88:1: warning: function declaration isn’t a prototype [-Wstrict-prototypes]
../../tinyos-main/tos/chips/atm128/atm128hardware.h:92:1: warning: function declaration isn’t a prototype [-Wstrict-prototypes]
../../tinyos-main/tos/chips/atm128/atm128hardware.h:92:23: warning: function declaration isn’t a prototype [-Wstrict-prototypes]
../../tinyos-main/tos/chips/atm128/atm128hardware.h:88:23: warning: function declaration isn’t a prototype [-Wstrict-prototypes]
--- compiling ../../../moose/avr.c
--- compiling ../../../moose/serial.c
--- linking main.elf
--- creating HEX image
--- creating EEPROM
--- creating extended listing file
--- creating symbol table

main.elf  :
section         size      addr
.data             26   8388864
.text           3942         0
.bss              11   8388890
.stab            540         0
.stabstr         189         0
.comment          17         0
.debug_info     1938         0
.debug_abbrev   1833         0
.debug_line       29         0
.debug_str       662         0
Total           9187
```
