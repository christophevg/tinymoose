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

## Hello TinyMoose

*Coming Soon...*
