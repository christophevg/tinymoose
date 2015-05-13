#include <TinyError.h>

interface SimpleSend {
  event void ready(void);
  command error_t send(uint8_t *bytes, uint8_t size);
}
