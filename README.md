# TinyMoose

An experiment on integrating [Moose](https://github.com/christophevg/moose) and [TinyOS](https://github.com/tinyos/tinyos-main)  
Christophe VG <contact@christophe.vg>  
[https://github.com/christophevg/tinymoose](https://github.com/christophevg/tinymoose)

## Introduction

So far, I've been implementing my own hardware abstraction layer on top of the Atmel family of mcu's, called [Moose](https://github.com/christophevg/moose). With this experiment, I'm trying to run TinyOS on my own hardware, implementing what's missing using Moose, like the XBee networking support.

## Rationale

The reason for this unholy matrimony originates from another experiment, where I want to compare the optimizations of TinyOS to those of the Functional Code Fusion paradigm, developed for [foo-lang](https://github.com/christophevg/foo-lang). To do this, I want comparable versions of the software running on the same hardware. The initial comparison was against hand-written code, now I want to compare to NesC/TinyOS-based code, so I need to layer TinyOS on top of Moose, or vise versa, creating TinyMoose ;-)

## Getting started

TinyMoose, builds on TinyOS and Moose. Both projects are on GitHub, and are included in this repo as submodules. The top-level Makefile ensures that everything is initialized, updated and built as needed.

```bash
$ make
*** initializing and updating submodules...
*** building NesC...
```

If building NesC fails, check `.nesc.build.log`, which contains all output.

Running the command a second time, doesn't do any harm, `make` will tell you all is up to date ;-)

```bash
$ make
make: `all' is up to date.
```

## TinyOS Support for ATMEGA1284p

The main TinyOS codebase doesn't contain support for the ATMEGA1284p, which is the MCU used in the hardware of this experiment. Luckily, Martin Cerveny wrote platform support for the Atmel AVR Raven, which runs on the same MCU. It can still be found in the TinyOS 2.x contrib repository, which is mirrored at [https://github.com/tyll/tinyos-2.x-contrib](https://github.com/tyll/tinyos-2.x-contrib).

Following the porting instructions, found in the [README](https://github.com/tinyos/tinyos-main/blob/master/support/make/README.md) of the [support/make](https://github.com/tinyos/tinyos-main/blob/master/support/make/) folder of the TinyOS main repository, I've ported this experimental platform implementation to the new (3.x) build infrastructure.

The code of this port is located in the [tinyos-contrib](tinyos-contrib) folder of this project, separated from the tinyos-main repository. It can be added to the main repository by copying the files from the contrib folder to the main folder, as explained in the [README](tinyos-contrib/README) in the contrib folder. This is only needed if we want to extract the `nesc1` command to only generate the `app.c` source code, as explained in the next section.

## Hardware

_Coming soon..._

## Examples

Every example builds from a single `make` command. It uses `nesc1` to generate the single C file that contains everything. Next, it uses Moose's build infrastructure to build it.

The output of `nesc1` is caught in `.nesc.generation.log`.

To construct the command line instructions for using `nesc1`, one can first call the normal build instruction `make raven` to initiate the normal TinyOS (3.x) build process. A `Makefile.tos` is provided to perform this operation:

```bash
$ make -f Makefile.tos raven
[INFO] compiling HelloAppC to a raven binary
nescc -o build/raven/main.exe   -Os -gcc=avr-gcc -Wnesc-all -fnesc-include=tos -fnesc-scheduler=TinySchedulerC,TinySchedulerC.TaskBasic,TaskBasic,TaskBasic,runTask,postTask -fnesc-cfile=build/raven/app.c -fnesc-separator=__ -I../../tinyos-main/tos/platforms/raven -I../../tinyos-main/tos/platforms/raven/chips/rf230 -I../../tinyos-main/tos/chips/rf230 -I../../tinyos-main/tos/chips/atm1284 -I../../tinyos-main/tos/chips/atm1284/adc -I../../tinyos-main/tos/chips/atm1284/pins -I../../tinyos-main/tos/chips/atm1284/i2c -I../../tinyos-main/tos/chips/atm1284/timer -I../../tinyos-main/tos/chips/atm128 -I../../tinyos-main/tos/chips/atm128/adc -I../../tinyos-main/tos/chips/atm128/pins -I../../tinyos-main/tos/chips/atm128/spi -I../../tinyos-main/tos/chips/atm128/i2c -I../../tinyos-main/tos/chips/atm128/timer -I../../tinyos-main/tos/lib/timer -I../../tinyos-main/tos/lib/serial -I../../tinyos-main/tos/lib/power -I../../tinyos-main/tos/lib/diagmsg -I../../tinyos-main/tos/lib/rfxlink/layers -I../../tinyos-main/tos/lib/rfxlink/util -mmcu=atmega1284p -fnesc-target=avr -fnesc-no-debug -DATM128_I2C_EXTERNAL_PULLDOWN=TRUE -DPLATFORM_RAVEN -Wall -Wshadow --param max-inline-insns-single=100000 -Wno-unused-but-set-variable -Wno-enum-compare -I../../tinyos-main/tos/system -I../../tinyos-main/tos/types -I../../tinyos-main/tos/interfaces -DIDENT_APPNAME=\"HelloAppC\" -DIDENT_USERNAME=\"xtof\" -DIDENT_HOSTNAME=\"redrover.local\" -DIDENT_USERHASH=0xabb4daa6L -DIDENT_TIMESTAMP=0x5548a2c7L -DIDENT_UIDHASH=0xbca85efdL -fnesc-dump=wiring -fnesc-dump='interfaces(!abstract())' -fnesc-dump='referenced(interfacedefs, components)' -fnesc-dumpfile=build/raven/wiring-check.xml HelloAppC.nc -lm  
HelloC.nc:2:26: error: moose/serial.h: No such file or directory
In file included from HelloAppC.nc:6:
In component `HelloC':
HelloC.nc: In function `Boot.booted':
HelloC.nc:10: implicit declaration of function `avr_init'
HelloC.nc:11: implicit declaration of function `serial_init'
``` 

The process fails due to Moose functionality not being available, but that's okay, since we want to reuse the Moose build infrastructure afterwards.

We can take the command starting with `nescc` (line 3) and issue it with an additional `-v` switch to get verbose output, **and** an additional `-I../../` switch to provide the references to the Moose header files:

```bash
$ nescc -o build/raven/main.exe -Os -gcc=avr-gcc -Wnesc-all -fnesc-include=tos -fnesc-scheduler=TinySchedulerC,TinySchedulerC.TaskBasic,TaskBasic,TaskBasic,runTask,postTask -fnesc-cfile=build/raven/app.c -fnesc-separator=__ -I../../ -I../../tinyos-main/tos/platforms/raven -I../../tinyos-main/tos/platforms/raven/chips/rf230 -I../../tinyos-main/tos/chips/rf230 -I../../tinyos-main/tos/chips/atm1284 -I../../tinyos-main/tos/chips/atm1284/adc -I../../tinyos-main/tos/chips/atm1284/pins -I../../tinyos-main/tos/chips/atm1284/i2c -I../../tinyos-main/tos/chips/atm1284/timer -I../../tinyos-main/tos/chips/atm128 -I../../tinyos-main/tos/chips/atm128/adc -I../../tinyos-main/tos/chips/atm128/pins -I../../tinyos-main/tos/chips/atm128/spi -I../../tinyos-main/tos/chips/atm128/i2c -I../../tinyos-main/tos/chips/atm128/timer -I../../tinyos-main/tos/lib/timer -I../../tinyos-main/tos/lib/serial -I../../tinyos-main/tos/lib/power -I../../tinyos-main/tos/lib/diagmsg -I../../tinyos-main/tos/lib/rfxlink/layers -I../../tinyos-main/tos/lib/rfxlink/util -mmcu=atmega1284p -fnesc-target=avr -fnesc-no-debug -DATM128_I2C_EXTERNAL_PULLDOWN=TRUE -DPLATFORM_RAVEN -Wall -Wshadow --param max-inline-insns-single=100000 -Wno-unused-but-set-variable -Wno-enum-compare -I../../tinyos-main/tos/system -I../../tinyos-main/tos/types -I../../tinyos-main/tos/interfaces -DIDENT_APPNAME=\"HelloAppC\" -DIDENT_USERNAME=\"xtof\" -DIDENT_HOSTNAME=\"redrover.local\" -DIDENT_USERHASH=0xabb4daa6L -DIDENT_TIMESTAMP=0x5548a2c7L -DIDENT_UIDHASH=0xbca85efdL -fnesc-dump=wiring -fnesc-dump='interfaces(!abstract())' -fnesc-dump='referenced(interfacedefs, components)' -fnesc-dumpfile=build/raven/wiring-check.xml -v HelloAppC.nc -lm  
nescc: 1.3.6
...
nesc1 -U__BLOCKS__ -fnesc-include=deputy_nodeputy -fnesc-gcc=avr-gcc -mmcu=atmega1284p -DATM128_I2C_EXTERNAL_PULLDOWN=TRUE -DPLATFORM_RAVEN -DIDENT_APPNAME="HelloAppC" -DIDENT_USERNAME="xtof" -DIDENT_HOSTNAME="redrover.local" -DIDENT_USERHASH=0xabb4daa6L -DIDENT_TIMESTAMP=0x5548a2c7L -DIDENT_UIDHASH=0xbca85efdL -DNESC=136 -I/usr/local/lib/ncc -I../../ -I../../tinyos-main/tos/platforms/raven -I../../tinyos-main/tos/platforms/raven/chips/rf230 -I../../tinyos-main/tos/chips/rf230 -I../../tinyos-main/tos/chips/atm1284 -I../../tinyos-main/tos/chips/atm1284/adc -I../../tinyos-main/tos/chips/atm1284/pins -I../../tinyos-main/tos/chips/atm1284/i2c -I../../tinyos-main/tos/chips/atm1284/timer -I../../tinyos-main/tos/chips/atm128 -I../../tinyos-main/tos/chips/atm128/adc -I../../tinyos-main/tos/chips/atm128/pins -I../../tinyos-main/tos/chips/atm128/spi -I../../tinyos-main/tos/chips/atm128/i2c -I../../tinyos-main/tos/chips/atm128/timer -I../../tinyos-main/tos/lib/timer -I../../tinyos-main/tos/lib/serial -I../../tinyos-main/tos/lib/power -I../../tinyos-main/tos/lib/diagmsg -I../../tinyos-main/tos/lib/rfxlink/layers -I../../tinyos-main/tos/lib/rfxlink/util -I../../tinyos-main/tos/system -I../../tinyos-main/tos/types -I../../tinyos-main/tos/interfaces -Wall -Wshadow -Wno-unused-but-set-variable -Wno-enum-compare -v -fnesc-tmpcfile=/var/folders/98/xs_z9zpx49lghsx5gpggfnsw0000gn/T//ccZ8UC1d.c -fnesc-include=nesc_nx -Wnesc-all -fnesc-include=tos -fnesc-scheduler=TinySchedulerC,TinySchedulerC.TaskBasic,TaskBasic,TaskBasic,runTask,postTask -fnesc-separator=__ -fnesc-target=avr -fnesc-no-debug -fnesc-dump=wiring -fnesc-dump=interfaces(!abstract()) -fnesc-dump=referenced(interfacedefs, components) -fnesc-dumpfile=build/raven/wiring-check.xml HelloAppC.nc -o build/raven/app.c
```

We're only interested in the generated `nesc1` command line, which produces `build/raven/app.c`. A cleaned up version, with pointers into the contrib folder is provided in the default `Makefile` in the example folder.

### Hello TinyMoose

The hello world example of TinyMoose, consists of one single `HelloC` component and accompanying `HelloAppC` application:

```c
#include <stdio.h>

#include "moose/avr.h"
#include "moose/serial.h"

module HelloC{
  uses interface Boot;
}

implementation{
  event void Boot.booted() {
    avr_init();
    serial_init();
    printf("Hello World\n");
  }
}
```

Functions `avr_init` and `serial_init` are calls into the Moose codebase and initialize the MCU and the serial support. Amongst others, the output of `printf` calls is rerouted to the serial connection.

```c
configuration HelloAppC {}

implementation{ 
	components HelloC, MainC;

	HelloC.Boot -> MainC.Boot;
}
```

The `HelloAppC` application  wires the `MainC.Boot` interface to `HelloC.Boot` which will receive the `Boot.booted` events and handles them, simply printing out `Hello World`.

Building the example requires a simple `make` command:

```bash
$ cd src/hello/
$ make
*** constructing build/main.c for Hello example...
*** adding Makefile to build Hello example...
*** building Hello example...
--- compiling main.c
../../tinyos-contrib/tos/chips/atm1284/atm128hardware.h:91:1: warning: function declaration isn’t a prototype [-Wstrict-prototypes]
../../tinyos-contrib/tos/chips/atm1284/atm128hardware.h:95:1: warning: function declaration isn’t a prototype [-Wstrict-prototypes]
../../tinyos-contrib/tos/chips/atm1284/atm128hardware.h:95:23: warning: function declaration isn’t a prototype [-Wstrict-prototypes]
../../tinyos-contrib/tos/chips/atm1284/atm128hardware.h:91:23: warning: function declaration isn’t a prototype [-Wstrict-prototypes]
--- linking main.elf
--- creating HEX image
--- creating EEPROM
--- creating extended listing file
--- creating symbol table

main.elf  :
section         size      addr
.data             26   8388864
.text           3832         0
.bss              10   8388890
.stab            540         0
.stabstr         189         0
.comment          17         0
.debug_info     1938         0
.debug_abbrev   1833         0
.debug_line       29         0
.debug_str       662         0
Total           9076
```

We can now move forward into the `build` folder:

```bash
$ cd build/
redrover:build xtof$ ls -l
total 392
-rw-r--r--  1 xtof  staff     52 May  5 13:26 Makefile
-rw-r--r--  1 xtof  staff  33022 May  5 13:26 main.c
-rw-r--r--  1 xtof  staff     13 May  5 13:26 main.eep
-rwxr-xr-x  1 xtof  staff  13625 May  5 13:26 main.elf
-rw-r--r--  1 xtof  staff  10875 May  5 13:26 main.hex
-rw-r--r--  1 xtof  staff  67095 May  5 13:26 main.lss
-rw-r--r--  1 xtof  staff  11416 May  5 13:26 main.lst
-rw-r--r--  1 xtof  staff  33240 May  5 13:26 main.map
-rw-r--r--  1 xtof  staff   2412 May  5 13:26 main.o
-rw-r--r--  1 xtof  staff   3029 May  5 13:26 main.sym
```

Using the Moose-based `Makefile` a `main.hex` is already compiled, which we now can use to program the hardware.

_Mind that you'll have to fiddle a bit with some environment variables to get the right port for avrdude. Take a look at the [Makefile](moose/Makfile) in the Moose folder._

```bash
$ make program
avrdude -p atmega1284p -P usb:5a:cb -c jtag2 -U flash:w:main.hex 
...
avrdude: 3858 bytes of flash written
...
avrdude done.  Thank you.
```

If you now hook up the hardware to a serial to USB adapter and issue a screen to monitor it, on boot you will see the output of the `printf` call:

<p align="center">
<img src="media/hello-world.png">
</p>
