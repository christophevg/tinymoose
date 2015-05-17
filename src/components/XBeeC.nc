#include <stdio.h>
#include <stdint.h>

#include "Timer.h"

#include "moose/xbee.h"

#define FRAME_SIZE 16

#include "frame.h"

module XBeeC {
  provides interface FrameReceive;
  provides interface FrameSend;
  provides interface XBeeFrame;

  uses interface Boot;
  uses interface Timer<TMilli> as Timer0;
}

implementation{
  // FrameSend
  command error_t FrameSend.send(frame_t *frame) {
    xbee_send((xbee_tx_t*)frame);
    return SUCCESS;
  }
  
  void handle_frame(xbee_rx_t *frame) {
    signal FrameReceive.received((frame_t*)frame);
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
    
    signal FrameSend.ready();
  }
  
  // Periodic Receive Loop
  
  task void receive() {
    xbee_receive();
  }

  event void Timer0.fired() {
    post receive();
  }
  
  // XBeeFrame
  command void XBeeFrame.set_size(frame_t *frame, uint16_t size) {
    ((xbee_tx_t*)frame)->size = size;
  }
  command void XBeeFrame.set_id(frame_t *frame, uint8_t id) {
    ((xbee_tx_t*)frame)->id = id;
  }
  command void XBeeFrame.set_address(frame_t *frame, uint64_t address) {
    ((xbee_tx_t*)frame)->address = address;
  }
  command void XBeeFrame.set_nw_address(frame_t *frame, uint16_t nw_address) {
    ((xbee_tx_t*)frame)->nw_address = nw_address;
  }
  command void XBeeFrame.set_radius(frame_t *frame, uint8_t radius) {
    ((xbee_tx_t*)frame)->radius = radius;
  }
  command void XBeeFrame.set_options(frame_t *frame, uint8_t options) {
    ((xbee_tx_t*)frame)->options = options;
  }
  command void XBeeFrame.set_data(frame_t *frame, uint8_t  *data) {
    ((xbee_tx_t*)frame)->data = data;
  }
}
