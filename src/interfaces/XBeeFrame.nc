#include <TinyError.h>

#include <stdint.h>

#define FRAME_SIZE 16

#include "frame.h"

interface XBeeFrame {
  command void set_size      (frame_t *frame, uint16_t size      );
  command void set_id        (frame_t *frame, uint8_t  id        );
  command void set_address   (frame_t *frame, uint64_t address   );
  command void set_nw_address(frame_t *frame, uint16_t nw_address);
  command void set_radius    (frame_t *frame, uint8_t  radius    );
  command void set_options   (frame_t *frame, uint8_t  options   );
  command void set_data      (frame_t *frame, uint8_t  *data     );
}
