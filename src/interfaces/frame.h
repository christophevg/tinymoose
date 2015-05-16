#ifndef __frame_h
#define __frame_h

#include <stdint.h>

// if there is no frame size specified ???!!
#ifndef FRAME_SIZE
#define FRAME_SIZE 16
#endif

typedef struct frame_t {
  uint8_t bytes[FRAME_SIZE];
} frame_t;

#endif
