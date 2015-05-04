# TinyMoose

An experiment on integrating Moose and TinyOS  
Christophe VG <contact@christophe.vg>  
[https://github.com/christophevg/tinymoose](https://github.com/christophevg/tinymoose)

## Introduction

So far, I've been implementing my own hardware abstraction layer on top of the
Atmel family of mcu's. With this experiment, I'm trying to run TinyOS on my own
hardware, implementing what's missing using Moose, like the XBee networking
support.

## Getting started

TinyMoose, builds on TinyOS and Moose. Both projects are on GitHub, and are
included in this repo as submodules. The top-level Makefile ensures that
everything is initialized, updated and built as needed.

```bash
$ make
*** initializing and updating moose submodules...
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
