module GreeterC {
  uses interface SimpleSend;
  uses interface SimpleReceive;
}

#include <stdio.h>

implementation {

  event void SimpleSend.ready() {
    printf("sending hello to parent...\n");
    call SimpleSend.send_str("hello parent!");
  }

  event void SimpleReceive.received(uint8_t *bytes, const uint8_t size) {
    int i;
    printf("received %d bytes : ", size);
    for(i=0; i<size; i++) {
      printf("%c", bytes[i]);
    }
    printf("\n");
  }
}
