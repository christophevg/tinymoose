module GreeterC {
  uses interface ExtendedSend;
  uses interface ExtendedReceive;
}

#include <stdio.h>

implementation {

// coordinator lives at 0
uint64_t ADDRESS    = 0x0000000000000000;
uint16_t NW_ADDRESS = 0x0000;

  event void ExtendedSend.ready() {
    printf("sending hello to coordinator @ "
           "address=%02x %02x %02x %02x %02x %02x %02x %02x "
           "nw_address=%02x %02x...\n",
           (uint8_t)(ADDRESS >> 56), (uint8_t)(ADDRESS >> 48),
           (uint8_t)(ADDRESS >> 40), (uint8_t)(ADDRESS >> 32),
           (uint8_t)(ADDRESS >> 24), (uint8_t)(ADDRESS >> 16),
           (uint8_t)(ADDRESS >>  8), (uint8_t)ADDRESS,
           (uint8_t)(NW_ADDRESS >> 8), (uint8_t)NW_ADDRESS);
    call ExtendedSend.send_str(ADDRESS, NW_ADDRESS, "hello coordinator!");
  }

  event void ExtendedReceive.received(uint64_t address, uint16_t nw_address,
                                      uint8_t *bytes, const uint8_t size)
  {
    int i;
    printf("received %d bytes from "
      "address=%02x %02x %02x %02x %02x %02x %02x %02x "
      "nw_address=%02x %02x : ",
      size,
      (uint8_t)(address >> 56), (uint8_t)(address >> 48),
      (uint8_t)(address >> 40), (uint8_t)(address >> 32),
      (uint8_t)(address >> 24), (uint8_t)(address >> 16),
      (uint8_t)(address >>  8), (uint8_t)address,
      (uint8_t)(nw_address >> 8), (uint8_t)nw_address);
    for(i=0; i<size; i++) {
      printf("%c", bytes[i]);
    }
    printf("\n");
  }
}
