#include <stdio.h>

module Engine1C {
  uses interface Boot;
  uses interface SimpleReceive;
}

implementation{
  event void Boot.booted() {
    printf("Engine 1 starting up...\n");
  }

  event void SimpleReceive.received(uint8_t *bytes, const uint8_t size) {
    int i;
    printf("Engine 1 received %d bytes : ", size);
    for(i=0; i<size; i++) {
      printf("%c", bytes[i]);
    }
    printf("\n");
  }
}
