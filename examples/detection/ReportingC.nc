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
    static unsigned long total_frames  = 0,
                         total_bytes   = 0,
                         samples       = 0;
    time_t now;
    xbee_metrics_t metrics;

    now           = clock_get_millis();
    metrics       = xbee_reset_counters();
    total_frames += metrics.frames;
    total_bytes  += metrics.bytes;
    samples++;

    _log("metrics: cycles: %lu (ev:%u us) | xbee: %d frames (avg:%u/tot:%lu) / %i bytes (avg:%u/tot:%lu)\n",
         cycles, (unsigned int)((now * 1000.0) / cycles),
         metrics.frames, (unsigned int)(total_frames / samples), total_frames,
         metrics.bytes,  (unsigned int)(total_bytes  / samples), total_bytes);
    
  }
  
  event void ReportingTimer.fired() { post report();  }
}
