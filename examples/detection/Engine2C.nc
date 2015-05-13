#include <stdio.h>

module Engine1C {
  uses interface Boot;
}

implementation{
  event void Boot.booted() {
    printf("Engine 2 starting up...\n");
  }
}
