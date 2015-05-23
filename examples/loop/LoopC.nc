#include <stdio.h>

#include "avr/delay.h"

#include "moose/avr.h"
#include "moose/serial.h"

module LoopC {
	uses interface Boot;
  uses interface Timer<TMilli> as LoopTimer;
}

implementation{

  #define INTERVAL 2000L

	event void Boot.booted() {
    avr_init();
    serial_init();
    call LoopTimer.startPeriodic(INTERVAL * 250);
  }
  
  task void tick() {
    _delay_ms(200);
  }

  event void LoopTimer.fired() {
    post tick();
  }
}
