#include <TinyError.h>

#include "frame.h"

interface FrameSend {
  event void ready(void);
  command error_t send(frame_t *frame);
}
