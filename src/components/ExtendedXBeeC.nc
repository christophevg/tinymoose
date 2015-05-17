module ExtendedXBeeC {
  provides interface ExtendedSend;
  provides interface ExtendedReceive;

  uses interface FrameSend;
  uses interface FrameReceive;
  uses interface XBeeFrame;
}

#include "moose/xbee.h"

implementation {

  command error_t ExtendedSend.send(uint64_t address, uint16_t nw_address,
                                    uint8_t *bytes, uint8_t size)
  {
    frame_t frame;

    call XBeeFrame.set_size(&frame, size);
    call XBeeFrame.set_id(&frame, XB_TX_NO_RESPONSE);
    call XBeeFrame.set_address(&frame, address);
    call XBeeFrame.set_nw_address(&frame, nw_address);
    call XBeeFrame.set_radius(&frame, XB_MAX_RADIUS);
    call XBeeFrame.set_options(&frame, XB_OPT_NONE);
    call XBeeFrame.set_data(&frame, bytes);
    
    call FrameSend.send(&frame);
    
    return SUCCESS;
  }

  command error_t ExtendedSend.send_str(uint64_t address, uint16_t nw_address,
                                        const char *string)
  {
    return call ExtendedSend.send(address, nw_address, (uint8_t*)string, strlen(string));
  }

  command error_t ExtendedSend.broadcast(uint8_t *bytes, uint8_t size) {
    return call ExtendedSend.send(XB_BROADCAST, XB_NW_BROADCAST, bytes, size);
  }

  command error_t ExtendedSend.broadcast_str(const char *string) {
    return call ExtendedSend.broadcast((uint8_t*)string, strlen(string));
  }

  event void FrameSend.ready(void) {
    signal ExtendedSend.ready();
  }
  
  event void FrameReceive.received(frame_t *frame) {
    signal ExtendedReceive.received(((xbee_rx_t*)frame)->address,
                                    ((xbee_rx_t*)frame)->nw_address,
                                    ((xbee_rx_t*)frame)->data,
                                    ((xbee_rx_t*)frame)->size);
  }
}
