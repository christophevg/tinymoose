module SimpleXBeeC {
  provides interface SimpleSend;
  provides interface SimpleReceive;

  uses interface FrameSend;
  uses interface FrameReceive;
  uses interface XBeeFrame;
}

#include "moose/xbee.h"

implementation {

  command error_t SimpleSend.send(uint8_t *bytes, const uint8_t size) {
    frame_t frame;

    call XBeeFrame.set_size(&frame, size);
    call XBeeFrame.set_id(&frame, XB_TX_NO_RESPONSE);
    call XBeeFrame.set_address(&frame, XB_COORDINATOR);
    call XBeeFrame.set_nw_address(&frame, XB_NW_ADDR_UNKNOWN);
    call XBeeFrame.set_radius(&frame, XB_MAX_RADIUS);
    call XBeeFrame.set_options(&frame, XB_OPT_NONE);
    call XBeeFrame.set_data(&frame, bytes);
    
    call FrameSend.send(&frame);
    
    return SUCCESS;
  }

  command error_t SimpleSend.send_str(const char* string) {
    call SimpleSend.send((uint8_t*)string, strlen(string));
  }


  event void FrameSend.ready(void) {
    signal SimpleSend.ready();
  }
  
  event void FrameReceive.received(frame_t *frame) {
    signal SimpleReceive.received(((xbee_rx_t*)frame)->data,
                                  ((xbee_rx_t*)frame)->size);
  }
}
