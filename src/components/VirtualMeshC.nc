module VirtualMeshC {
  provides interface MeshSend;
  provides interface MeshReceive;

  uses interface FrameSend;
  uses interface FrameReceive;
  uses interface XBeeFrame;
}

#include "moose/xbee.h"

implementation {
  
  uint16_t me;
  uint16_t parent;
  bool     router;
  
  command uint16_t MeshSend.get_own_nw_address(void) {
    return me;
  }
  
  // volatile, because it is changed from interrupt and should not be optimized
  // form functions that don't change it.
  volatile uint64_t other_address    = XB_COORDINATOR;
  volatile uint16_t other_nw_address = XB_NW_ADDR_UNKNOWN;
  
  void wait_for_end_device() {
    printf("I'm a router, waiting for end-device to join...\n");
    // only routers go into this wait-loop
    // while our parent address (the other side of the link) is the coordinator
    // we wait for messages to arrive. these are join requests from the end-node
    // which cause the other_address to be recorded.
    while(other_address == XB_COORDINATOR) {
      _delay_ms(500L);
      xbee_receive(); // needed because the periodic timer doesn't interrupt
    }
  }

  void wait_for_router() {
    uint8_t l;

    printf("I'm an end-node, sending out join requests...\n");
    // only end-nodes go into this wait-loop
    // while our parent address (the other side of the link) is the coordinator
    // we send out a real ;-) broadcast indicating we want to join. this will
    // only reach our upstream router. once this router starts sending out
    // messages, that reach us, its actual address will be recorded and we exit
    // this loop.
    while(other_address == XB_COORDINATOR) {
      xbee_tx_t frame;
      frame.size        = 4;
      frame.id          = XB_TX_NO_RESPONSE;
      frame.address     = XB_BROADCAST;
      frame.nw_address  = XB_NW_BROADCAST;
      frame.radius      = 0x01;
      frame.options     = XB_OPT_NONE;
      frame.data        = (uint8_t*)"join";
      xbee_send(&frame);

      for(l=0; l<5 && other_address == XB_COORDINATOR; l++) {
        _delay_ms(100L);
        xbee_receive(); // needed because the periodic timer doesn't interrupt
      }
    }
  }
  
  void mesh_init(void) {
    // cache own and parent's nw address
    me     = xbee_get_nw_address();
    parent = xbee_get_parent_address();
    router = parent == XB_NW_ADDR_UNKNOWN;

    if(router) {
      wait_for_end_device();
    } else {
      wait_for_router();
    }
  }

  void _send(uint64_t address, uint16_t nw_address,
             uint16_t from, uint16_t hop, uint16_t to,
             uint8_t* payload, uint8_t size)
  {
    frame_t frame;
    uint8_t* bytes = malloc(3*sizeof(uint16_t)+size);

    // add broadcast hop and destination
    bytes[0] = (uint8_t)(from >> 8);  bytes[1] = (uint8_t)(from);
    bytes[2] = (uint8_t)(hop  >> 8);  bytes[3] = (uint8_t)(hop );
    bytes[4] = (uint8_t)(to   >> 8);  bytes[5] = (uint8_t)(to  );

    // add the actual payload
    memcpy(&(bytes[6]), payload, size);

    call XBeeFrame.set_size(&frame, size + 3*2);
    call XBeeFrame.set_id(&frame, XB_TX_NO_RESPONSE);
    call XBeeFrame.set_address(&frame, address);
    call XBeeFrame.set_nw_address(&frame, nw_address);
    call XBeeFrame.set_radius(&frame, 0x01);           // only go to parent/hop
    call XBeeFrame.set_options(&frame, XB_OPT_NONE);
    call XBeeFrame.set_data(&frame, bytes);
    
    call FrameSend.send(&frame);
  }
  
  void _send_from(uint16_t from, uint16_t to, uint8_t *bytes, uint8_t size) {
    uint16_t hop16;
    uint64_t hop64;
    if(router) {                // we're the router, parent = coordinator
      hop16 = XB_COORDINATOR;
      hop64 = XB_COORDINATOR;
    } else {                    // we're the end-device, parent = router
      hop16 = parent;
      hop64 = other_address;
    }
    _send(hop64, hop16, from, hop16, to, bytes, size);

    signal MeshSend.transmitted(from, to, hop16, bytes, size);

    // if we're a router, we need to send a copy to our child
    if(router) { 
      _send(other_address, other_nw_address, from, hop16, to, bytes, size);
    }    
  }
  
  command error_t MeshSend.send(uint16_t to, uint8_t *bytes, uint8_t size) {
    _send_from(me, to, bytes, size);
    return SUCCESS;
  }

  command error_t MeshSend.send_str(uint16_t to,
                                    const char *string)
  {
    return call MeshSend.send(to, (uint8_t*)string, strlen(string));
  }

  command error_t MeshSend.broadcast(uint8_t *bytes, uint8_t size) {
    return call MeshSend.send(XB_NW_BROADCAST, bytes, size);
  }

  command error_t MeshSend.broadcast_str(const char *string) {
    return call MeshSend.broadcast((uint8_t*)string, strlen(string));
  }

  event void FrameSend.ready(void) {
    mesh_init();
    signal MeshSend.ready();
  }
  
  event void FrameReceive.received(frame_t *f) {
    xbee_rx_t *frame;
    uint16_t source, from, hop, to;

    frame = (xbee_rx_t*)(f);

    // if this is the first message (== other node), cache its addresses
    if(other_nw_address == XB_NW_ADDR_UNKNOWN) {
      other_address    = frame->address;
      other_nw_address = frame->nw_address;
    }

    // don't further process (real) broadcast from end-device = join
    if(frame->options == 0x42) { return; }

    source = frame->nw_address;
    // parse additional routing information
    from   = frame->data[1] | frame->data[0] << 8;
    hop    = frame->data[3] | frame->data[2] << 8;
    to     = frame->data[5] | frame->data[4] << 8;

    signal MeshReceive.received(source,
                                from, to, hop,
                                &(frame->data[6]), frame->size-6);

    // if we're a router and not the final destination, pass it on to our parent
    if(to != me && router) {
      _send_from(from, to, &(frame->data[6]), frame->size-6);
    }
  }
}
