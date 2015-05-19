#include <stdio.h>
#include <stdint.h>

#include "moose/clock.h"

#include "log.h"

module LightReadingC {
  uses interface MeshSend;
  uses interface MeshReceive;
  uses interface Timer<TMilli> as LightReadingTimer;
}

implementation {
  #define DESTINATION            0x0000
  #define LIGHT_SENSOR_PORT      PORTA  // PA0
  #define LIGHT_SENSOR_IO        DDRA   // IO direction
  #define LIGHT_SENSOR_PIN       0
  #define LIGHTREADING_INTERVAL  5000L  // measure/send lightreading every 5s
  
  // we start when the meshed network is ready ...
  // - prepare the ADC for reading
  // - start clock
  // - setup periodic sending of lightreadings

  event void MeshSend.ready() {
    avr_adc_init();                 // initialize the ADC for normal readings
    clock_init();
    call LightReadingTimer.startPeriodic(LIGHTREADING_INTERVAL * 250);
    _log("Light reading started...\n");
  }
  
  task void measure_and_send(void) {
    uint16_t reading;               // the 16-bit reading from the ADC
    uint8_t  values[2];             // the bytes containing the reading in bytes

    // read light sensor
    reading = avr_adc_read(LIGHT_SENSOR_PIN);
    values[0] = (reading >> 8);
    values[1] = reading;
  
    _log("light reading: %02x %02x\n", values[0], values[1]);

    // and send it to the coordinator through the mesh
    call MeshSend.send(DESTINATION, values, 2);
  }
  
  event void LightReadingTimer.fired() { post measure_and_send();  }

  // unused

  event void MeshSend.transmitted(uint16_t from, uint16_t to, uint16_t hop,
                                  uint8_t *bytes, uint8_t size) {}

  event void MeshReceive.received(uint16_t source,
                                  uint16_t from, uint16_t to, uint16_t hop,
                                  uint8_t *bytes, uint8_t size) {}
}
