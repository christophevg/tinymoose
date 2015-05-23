#include <stdio.h>
#include <stdint.h>

#include "moose/clock.h"

#include "log.h"

volatile unsigned long cycles = 0;

module ReportingC {
  uses interface Boot;
  uses interface Timer<TMilli> as ReportingTimer;
}

implementation {

  #define REPORTING_INTERVAL 15000L

  event void Boot.booted() {
    clock_init();
    call ReportingTimer.startPeriodic(REPORTING_INTERVAL * 250);
  }
  
  task void report(void) {
    _log("metrics: cycles: %lu (ev:%u us)\n",
         cycles, (unsigned int)((clock_get_millis() * 1000.0) / cycles));
  }
  
  event void ReportingTimer.fired() { post report();  }
}
