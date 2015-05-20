#include <stdio.h>
#include <stdint.h>

#include "moose/clock.h"

#include "log.h"

module HeartbeatingC {
  uses interface MeshSend;
  uses interface MeshReceive;
  uses interface Timer<TMilli> as ValidationTimer;
  uses interface Timer<TMilli> as SharingTimer;
}

implementation {
  
  // configuration

  #define FORWARD_INTERVAL    1000L   // forwards must be completed within 1s
  #define VALIDATION_INTERVAL 5000L   // interval to check trust of nodes
  #define SHARING_INTERVAL    7500L   // interval to broadcast reputation info
  #define INDIRECT_THRESHOLD     0.9  // lower limit for including indirect info
  #define AGING_WEIGHT           0.98 // factor to age reputation
  #define TRUST_LOWER_LEVEL      0.25 // trust is lost below this level

  // payload consists of 2 bytes for the network address of the node
  //                 and 4 bytes for the float typed alpha param
  //                 and 4 bytes for the float typed beta  param
  //                  = 10 bytes payload
  #define PAYLOAD_SIZE          10
  #define MAX_NODES              5  // maximum number of tracked neighbours

  // private type

  typedef struct tracked {
    time_t          timeout;
    uint8_t         size;
    uint8_t*        payload;
    struct tracked* next;
  } tracked_t;

  typedef struct {
    uint16_t   address;    // the network address of the node
    tracked_t* queue;      // queue of tracked
    uint8_t    msg_count;  // number of messages expected to be forwarded
    uint8_t    incidents;  // counter for incidents
    float      alpha;      // params to determine reputation
    float      beta;
    float      trust;      // to trust or not to trust, that is the question
  } reputation_node_t;

  // internal data

  static reputation_node_t nodes[MAX_NODES];
  static uint8_t           node_count = 0;

  // our own cached address
  static uint16_t me;

  // NOTE this is a very basic implementation, we might need to implement it 
  // with a tree or a hashtable based on the node's address
  // since the number of nodes is at most 3, this loop is as good ;-)
  static reputation_node_t* _get_node(uint16_t address) {
    uint8_t i;
    for(i=0; i<node_count; i++) {
      if(nodes[i].address == address) { return &nodes[i]; }
    }
    // unknown node, create a new one and return that
    if(node_count >= MAX_NODES) {
      return NULL;
    }
    nodes[node_count].address   = address;
    nodes[node_count].queue     = NULL;
    nodes[node_count].msg_count = 0;
    nodes[node_count].incidents = 0;
    nodes[node_count].trust     = 0;
    
    return &nodes[node_count++];
  }

  static void _track(reputation_node_t* node, uint8_t size, uint8_t* payload) {
    // create tracked payload structure
    tracked_t* tracked;
    tracked = malloc(sizeof(tracked_t));
    tracked->timeout = clock_get_millis() + FORWARD_INTERVAL;
    tracked->size = size;
    tracked->payload = malloc(size*sizeof(uint8_t));
    memcpy(tracked->payload, payload, size);

    // add the tracked payload to the queue - works even with empty list ;-)
    tracked->next = node->queue;
    node->queue   = tracked;
  
    // count all tracked messages
    node->msg_count++;
  }

  static void _untrack(reputation_node_t* node, uint8_t size, uint8_t* payload) {
    tracked_t *tracked, *parent;
    tracked = node->queue;
    parent  = NULL;
  
    while(tracked != NULL) {
      if( tracked->size == size && 
          memcmp(tracked->payload, payload, size) == 0 )
      {
        // found payload, remove it
      
        if(parent == NULL) {
          node->queue = tracked->next;
        } else {
          parent->next = tracked->next;
        }
        _log("RP: cleared payload from %02x %02x : size=%d\n",
             (uint8_t)(node->address >> 8), (uint8_t)node->address, size);
        return;
      }
      parent  = tracked;
      tracked = tracked->next;
    }
    _log("RP: unexpected payload from %02x %02x\n",
         (uint8_t)(node->address >> 8), (uint8_t)node->address);
  }
  
  static uint8_t _remove_late(reputation_node_t* node) {
    tracked_t *tracked, *parent;
    uint8_t   lates = 0;
    tracked = node->queue;
    parent  = NULL;

    while(tracked != NULL) {
      if( tracked->timeout < clock_get_millis() ) {
        _log("RP: late: %02x %02x\n",
             (uint8_t)(node->address >> 8), (uint8_t)node->address);
        // this one is late
        lates++;
        if(parent == NULL) {
          node->queue = tracked->next;
        } else {
          parent->next = tracked->next;
        }
      }
      parent  = tracked;
      tracked = tracked->next;
    }
    return lates;
  }

  // we start when the meshed network is ready ...
  // - retrieve own address
  // - start clock
  // - setup periodic handling of 
  //   - validating known nodes
  //   - broadcasting reputation information

  event void MeshSend.ready() {
    me = call MeshSend.get_own_nw_address();
    clock_init();
    call ValidationTimer.startPeriodic(VALIDATION_INTERVAL * 250);
    call SharingTimer.startPeriodic(SHARING_INTERVAL * 250);
  }

  task void validate() {
    uint8_t n;
    uint8_t failures;
    _log("RP: starting validation...\n");
    for(n=0; n<node_count; n++) {
      // count late/missing forwards
      failures = _remove_late(&nodes[n]);

      // update the reputation parameters
      nodes[n].alpha = (AGING_WEIGHT * nodes[n].alpha)
                     + nodes[n].msg_count - failures;
      nodes[n].beta  = (AGING_WEIGHT * nodes[n].beta )
                     + failures;

      // and compute trust
      nodes[n].trust = (nodes[n].alpha + 1)
                     / (nodes[n].alpha + nodes[n].beta + 2);

      _log("RP: validating node %d %02x %02x : fail=%d/%d : a=%.2f b=%.2f t=%.2f\n",
           n,
           (uint8_t)(nodes[n].address >> 8), (uint8_t)nodes[n].address,
           failures, nodes[n].msg_count,
           (double)nodes[n].alpha, (double)nodes[n].beta, (double)nodes[n].trust);

      // notify bad node
      if(nodes[n].trust < TRUST_LOWER_LEVEL) {
        _log("RP: trust lost\n");
        call MeshSend.send(nodes[n].address, (uint8_t*)"excluded", 8);
      }

      // reset message counter
      nodes[n].msg_count = 0;
    }
  }
  
  task void share() {
    union {
      struct {
        uint8_t node_msb;   // 1
        uint8_t node_lsb;   // 1
        float   alpha;      // 4
        float   beta;       // 4
      } values;
      uint8_t bytes[PAYLOAD_SIZE];
    } payload;
    uint8_t n;

    for(n=0; n<node_count; n++) {
      payload.values.node_msb  = (uint8_t)(nodes[n].address >> 8);
      payload.values.node_lsb  = (uint8_t)nodes[n].address;
      payload.values.alpha     = nodes[n].alpha;
      payload.values.beta      = nodes[n].beta;
      call MeshSend.broadcast(payload.bytes, PAYLOAD_SIZE);
    }
  }
  
  event void ValidationTimer.fired()  { post validate();  }
  event void SharingTimer.fired()     { post share();     }

  event void MeshReceive.received(uint16_t source,
                                  uint16_t from, uint16_t to, uint16_t hop,
                                  uint8_t *bytes, uint8_t size)
  {
    uint16_t address;
    reputation_node_t *sending_node, *of, *from_node;
    union {
      float value;
      uint8_t b[4];
    } alpha, beta;
    float weight;

    sending_node = _get_node(source);
    if( sending_node == NULL ) { return; }  // out of storage

    // tracking of MY messages
    if( from == me ) {
      _untrack(sending_node, size, bytes);
    } else if(size == PAYLOAD_SIZE) { // other options
      // a reputation message: parse node address, alpha and beta values.
      address = ((uint16_t)(bytes[0]) << 8) | bytes[1];
      if(address == me) { return; } // not interested in other's opinion ;-)
      of = _get_node(address);
      alpha.b[0] = bytes[2];
      alpha.b[1] = bytes[3];
      alpha.b[2] = bytes[4];
      alpha.b[3] = bytes[5];
      beta.b[0]  = bytes[6];
      beta.b[1]  = bytes[7];
      beta.b[2]  = bytes[8];
      beta.b[3]  = bytes[9];

      from_node = _get_node(from);
      if( from_node->trust > INDIRECT_THRESHOLD ) {
        // taking into account of indirect reputation information
        weight = (2 * from_node->alpha) /
                   ( (from_node->beta+2) * (alpha.value + beta.value + 2) 
                       * 2 * from_node->alpha );
        of->alpha += weight * alpha.value;
        of->beta  += weight * beta.value;
      }
    }    
  }
  
  event void MeshSend.transmitted(uint16_t from, uint16_t to, uint16_t hop,
                                  uint8_t *bytes, uint8_t size)
  {
    reputation_node_t* node;

    if( hop == to ) { return; } // final destination, no forward expected
    if( hop == XB_COORDINATOR ) { return; } // the coordinator doesn't forward
  
    // we expect to see this same payload again within the forward interval
    _log("RP: tracking payload from %02x %02x to %02x %02x : size=%d\n",
         (uint8_t)(hop >> 8), (uint8_t)hop, 
         (uint8_t)(to  >> 8), (uint8_t)to, size);
    node = _get_node(hop);
    if( node == NULL ) { return; }  // out of storage
    _track(node, size, bytes);
  }
}
