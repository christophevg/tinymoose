#include <stdio.h>

#include "moose/avr.h"
#include "moose/serial.h"
#include "moose/clock.h"

module ClockC {
	uses interface Boot;
  uses interface Timer<TMilli> as ClockTimer;
}

implementation{
	event void Boot.booted() {
    avr_init();
    serial_init();
    clock_init();
    call ClockTimer.startPeriodic(1000L * 250);   // magico !
    printf("now = 0   ");
  }
  
  time_t  max    = 9999;
  uint8_t length = 4;

  #define BACK_SPACE 8

  task void tick() {
    int i;
    time_t now = clock_get_millis();
    for(i=0;i<length;i++) { printf("%c", BACK_SPACE); }
    printf("%lu", now);
    if(now > max) {
      length++;
      max = max * 10 + 9;
    }
  }

  event void ClockTimer.fired() {
    post tick();
  }
}
