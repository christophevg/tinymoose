#include <stdio.h>

#include "moose/avr.h"
#include "moose/serial.h"

module MooseC {
  uses interface Boot;
}

implementation{
  event void Boot.booted() {
    avr_init();
    serial_init();
    printf("Moose support active...\n");
  }
}
