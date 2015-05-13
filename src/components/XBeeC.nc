#include <stdio.h>
#include <stdint.h>

#include "Timer.h"

#include "moose/xbee.h"

module XBeeC {
  provides interface SimpleSend;
  provides interface SimpleReceive;

  uses interface Boot;
  uses interface Timer<TMilli> as Timer0;
}

implementation{
  // SimpleSend
  command error_t SimpleSend.send(uint8_t *bytes, const uint8_t size) {
    xbee_tx_t frame;

    frame.size        = size;
    frame.id          = XB_TX_NO_RESPONSE;
    frame.address     = XB_COORDINATOR;
    frame.nw_address  = XB_NW_ADDR_UNKNOWN;
    frame.radius      = XB_MAX_RADIUS;
    frame.options     = XB_OPT_NONE;
    frame.data        = bytes;

    xbee_send(&frame);
    
    return SUCCESS;
  }
  
  command error_t SimpleSend.send_str(const char* string) {
    call SimpleSend.send((uint8_t*)string, strlen(string));
  }

  void handle_frame(xbee_rx_t *frame) {
    signal SimpleReceive.received(frame->data, frame->size);
  }
  
  event void Boot.booted() {
    uint16_t address, parent;
    
    xbee_init();
    printf("XBee support active...\n");

    call Timer0.startPeriodic(100);
    xbee_on_receive(handle_frame);
    printf("on_receive handler wired...\n");
    
    printf("Waiting for association...\n");
    xbee_wait_for_association();    // wait until the network is available
  
    address = xbee_get_nw_address();
    parent  = xbee_get_parent_address();
  
    printf("my address : %02x %02x\n", (uint8_t)(address >> 8), (uint8_t)address);
    printf("my parent  : %02x %02x\n", (uint8_t)(parent  >> 8), (uint8_t)parent );
    
    signal SimpleSend.ready();
  }
  
  // Periodic Receive Loop
  
  task void receive() {
    xbee_receive();
  }

  event void Timer0.fired() {
    post receive();
  }
}
