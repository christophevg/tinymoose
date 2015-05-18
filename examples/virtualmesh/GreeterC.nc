module GreeterC {
  uses interface MeshSend;
  uses interface MeshReceive;
}

#include <stdio.h>

implementation {

// coordinator lives at 0
uint16_t NW_ADDRESS = 0x0000;

  event void MeshSend.ready() {
    // send a unicast message to the coordinator
    printf("sending hello to coordinator @ %02x %02x...\n",
           (uint8_t)(NW_ADDRESS >> 8), (uint8_t)NW_ADDRESS);
    call MeshSend.send_str(NW_ADDRESS, "hello coordinator!");

    // broadcast a message
    printf("sending hello message to all...\n");
    call MeshSend.broadcast_str("hello everybody!");
  }

  event void MeshSend.transmitted(uint16_t from, uint16_t to, uint16_t hop,
                                  uint8_t *bytes, uint8_t size)
  {
    // TODO
  }

  event void MeshReceive.received(uint16_t source,
                                  uint16_t from, uint16_t to, uint16_t hop,
                                  uint8_t *bytes, uint8_t size)
  {
    int i;
    printf("received %d bytes from %02x %02x, "
           "origin %02x %02x, destination %02x %02x, via %02x %02x : ",
      size,
      (uint8_t)(source >> 8), (uint8_t)source,
      (uint8_t)(from   >> 8), (uint8_t)from,
      (uint8_t)(to     >> 8), (uint8_t)to,
      (uint8_t)(hop    >> 8), (uint8_t)hop
    );
    for(i=0; i<size; i++) {
      printf("%c", bytes[i]);
    }
    printf("\n");
  }
}
