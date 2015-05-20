#include <stdio.h>
#include <stdint.h>

#include "moose/clock.h"
#include "sha1.h"

#include "log.h"

module HeartbeatingC {
  uses interface MeshSend;
  uses interface MeshReceive;
  uses interface Timer<TMilli> as HeartbeatTimer;
  uses interface Timer<TMilli> as ProcessingTimer;
}

implementation {

  #define HEARTBEAT_INTERVAL    3000L  // send out a heartbeat every 3s
  #define PROCESSING_INTERVAL   5000L  // process every 1s
  
  #define MAX_INCIDENTS          3  // number of incidents before trust is gone

  #define MAX_NODES              5  // maximum number of tracked neighbours
  // payload consists of  1 byte for the heartbeat sequence
  //                 and  4 bytes for the node's time in millis
  //                 and 20 bytes for the SHA1 hash of sequence + millis
  //                   = 25 bytes payload
  #define PAYLOAD_SIZE          25  // allows for constant length arrays

  // private type

  // struct to keep track of nodes' last seen time and status
  typedef struct {
    uint16_t address;    // the network address of the node
    uint8_t  seq;        // last sequence id seen
    time_t   seen;       // the time when we saw the node (our time)
    uint8_t  incidents;  // counter for incidents
    bool     trust;      // to trust or not to trust, that is the question
  } heartbeat_node_t;

  // internal data

  // keep last seen time for each node
  static heartbeat_node_t nodes[MAX_NODES];
  static uint8_t          node_count = 0;

  // our own cached address
  static uint16_t me;

  static void _log_node(const char* msg, heartbeat_node_t* node) {
    _log("HB: %s : %02x %02x = seq: %d seen: %lu incidents: %d trust: %d\n",
         msg,
         (uint8_t)(node->address >> 8), (uint8_t)node->address,
         node->seq, node->seen, node->incidents, node->trust);
  }

  // NOTE this is a very basic implementation, we might need to implement it 
  // with a tree or a hashtable based on the node's address
  // since the number of nodes is at most 3, this loop is as good ;-)
  static heartbeat_node_t* _get_node(uint16_t address) {
    uint8_t i;
    
    for(i=0; i<MAX_NODES; i++) {
      if(nodes[i].address == address) { return &nodes[i]; }
    }
    // unknown node, create a new one and return that
    if(node_count >= MAX_NODES) {
      printf("FAIL: max nodes storage reached.\n");
      return NULL;
    }
    nodes[node_count].address   = address;
    nodes[node_count].seq       = 0;
    nodes[node_count].seen      = 0;
    nodes[node_count].incidents = 0;
    nodes[node_count].trust     = TRUE;
    _log_node("new node", &nodes[node_count]);
  
    nodes[node_count].address = address;
    return &nodes[node_count++];
  }

  // we start when the meshed network is ready ...
  // - retrieve own address
  // - start clock
  // - setup periodic handling of 
  //   - heartbeat sending
  //   - processing of accumulated information

  event void MeshSend.ready() {
    me = call MeshSend.get_own_nw_address();
    clock_init();
    call HeartbeatTimer.startPeriodic(HEARTBEAT_INTERVAL * 250);
    call ProcessingTimer.startPeriodic(PROCESSING_INTERVAL * 250);
  }
  
  task void beat() {
    // a heartbeat sequence counter
    static uint8_t heartbeat = 0;

    uint32_t millis;
    sha1_t sha1;
    uint8_t payload[PAYLOAD_SIZE];

    // add and increase the heartbeat sequence number
    payload[0] = ++heartbeat;

    // get the time
    millis = clock_get_millis();
    payload[1] = millis >> 24;
    payload[2] = millis >> 16;
    payload[3] = millis >>  8;
    payload[4] = millis;

    // create signature
    sha1 = SHA1Compute((const uint8_t*)&(payload), 5);
    if(sha1.result == shaSuccess) {
      memcpy(&payload[5], &sha1.hash, SHA1HashSize);
    }
    _log("HB: sending heartbeat %02x\n", payload[0]);
    call MeshSend.broadcast(payload, PAYLOAD_SIZE);
  }
  
  task void process() {
    uint8_t i;
    time_t now;

    now = clock_get_millis();

    for(i=0; i<node_count; i++) {
      if(nodes[i].trust) {
        if( now - nodes[i].seen > HEARTBEAT_INTERVAL) {
          nodes[i].incidents++;
          _log("HB: late heartbeat %02x %02x : %i\n",
               (uint8_t)(nodes[i].address >> 8), (uint8_t)(nodes[i].address),
               nodes[i].incidents);
        
        }

        if( nodes[i].incidents >= MAX_INCIDENTS ) {
          nodes[i].trust = FALSE;
          _log("HB: trust lost %02x %02x\n",
               (uint8_t)(nodes[i].address >> 8), (uint8_t)(nodes[i].address));
        }
      }
    }    
  }

  event void HeartbeatTimer.fired()  { post beat();  }
  event void ProcessingTimer.fired() { post process(); }

  event void MeshReceive.received(uint16_t source,
                                  uint16_t from, uint16_t to, uint16_t hop,
                                  uint8_t *bytes, uint8_t size)
  {
    heartbeat_node_t* node;
    sha1_t sha1;

    // skip our own heartbeat messages
    if(from == me) { return; }

    // quick check if packet might be a heartbeat packet, based on size
    // it MUST be equal to PAYLOAD_SIZE
    if( size != PAYLOAD_SIZE ) { return; }

    node = _get_node(from);

    if( node == NULL )  { return; }   // out of storage :-(
    if( ! node->trust ) { return; }   // don't handle untrusted nodes

    // verify payload -> signature
    sha1 = SHA1Compute((const uint8_t*)bytes, 5);
  
    if(sha1.result == shaSuccess &&
       memcmp(sha1.hash, &bytes[5], SHA1HashSize) == 0)
    {
      node->seq  = bytes[0];
      node->seen = clock_get_millis();
      _log("HB: received heartbeat %02x %02x : %i\n",
           (uint8_t)(from >> 8), (uint8_t)(from), node->incidents);
    } else {
      node->incidents++;
      _log("HB: FAILED sha1 check %02x %02x : %i\n",
           (uint8_t)(from >> 8), (uint8_t)(from), node->incidents);
    }
  }
  
  // unused
  
  event void MeshSend.transmitted(uint16_t from, uint16_t to, uint16_t hop,
                                  uint8_t *bytes, uint8_t size) {}
}
